

%%

cen = flyTracks.centroid;
padding_sz = 15;
frame_rate = 15;

save_dir = 'D:\decathlon_data_and_analysis\decathlon_analysis\bout_movies\';
fh=figure;
fh.Color = [1 1 1];
ah1 = subplot(1,2,1);
ah2 = subplot(1,2,2);
hold(ah1,'on');
imh = imagesc(zeros(1,1),'Parent',ah1);
colormap('gray');
uistack(imh,'bottom');
lh1 = plot(NaN,NaN,'o','MarkerFaceColor','k',...
    'MarkerEdgeColor','none','MarkerSize',16,'Parent',ah1);
hold(ah2,'on');
xx = -padding_sz:padding_sz;
ss = medfilt1(speed,lag_thresh,[],1);
lh2 = plot(xx,NaN(size(xx)),'k-','LineWidth',2,'Parent',ah2);
maxy = nanstd(ss(:))*4;
ylabel(ah2,'speed (pixels/sec)','FontSize',14);
xlabel(ah2,'\Delta frame number','FontSize',14);
plot([-padding_sz padding_sz],[spd_thresh spd_thresh],'r--','LineWidth',2,'Parent',ah2);
plot([0 0],[0 maxy],'k--','LineWidth',2,'Parent',ah2);
set(ah2,'XLim',[-padding_sz padding_sz],'YLim',[0 maxy]);
fh.Position = [1924,185,1903,668]; pause(0.2);
for i=1:numel(idx)
    fname = sprintf('%sbout_mov_fly%i.mp4',save_dir,i);
    vid = VideoWriter(fname,'MPEG-4');
    vid.FrameRate = frame_rate;
    open(vid);
    nbouts = size(idx{i},1);
    roi = flyTracks.ROI_coords(i,:);
    roi = [floor(roi(1:2)) ceil(roi(3:4))];
    [x,y] = meshgrid(roi(1):roi(3),roi(2):roi(4));
    kde = ksdensity([cen(:,1,i),cen(:,2,i)],[x(:) y(:)]);
    imh.CData = log(reshape(kde,numel(roi(2):roi(4)),numel(roi(1):roi(3))));
    set(ah1,'XTick',[],'YTick',[]);axis(ah1,'equal','tight');
    ct=1;
    prev_idx = -50;
    if nbouts > 0
        for j=1:ceil(size(ss,1)*0.03)
            b = idx{i}(ct,:);
    %         if j < b(1)-padding_sz && j > prev_idx+padding_sz
    %             j = b(1)-padding_sz;
    %         end

            title(ah1,sprintf('Fly %i, bout %i',i,ct),'FontSize',14);
            xlabel(ah1,sprintf('Frame: %i',j),'FontSize',14);
            if j==b(1)
                lh1.MarkerFaceColor = 'r';
            elseif j==b(2)+1
                prev_idx = b(2);
                ct = ct+1;
                lh1.MarkerFaceColor = 'k';
            end

            lh1.XData = cen(j,1,i) - roi(1);
            lh1.YData = cen(j,2,i) - roi(2);
            r = double(j-padding_sz:j+padding_sz);
            r(r<1|r>size(ss,1))=NaN;
            yy = NaN(size(xx));
            yy(~isnan(r)) = ss(r(~isnan(r)),i);
            lh2.YData = yy;
            drawnow
            pause(1/frame_rate);
            curr_frame = getframe(fh);
            writeVideo(vid,curr_frame.cdata);
        end
    end
    close(vid);
end