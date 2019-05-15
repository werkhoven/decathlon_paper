function vis_movement_bouts(flyTracks,bout_idx,padding_sz,bouts_per_roi)

fh = figure;
ah = gca;
lh = plot(NaN,NaN,'o','MarkerFaceColor','k','MarkerEdgeColor','none','MarkerSize',8);
for i=75:numel(bout_idx)
    nbouts = size(bout_idx{i},1);
    nbouts(nbouts>bouts_per_roi) = bouts_per_roi;
    roi = flyTracks.ROI_coords(i,:);
    set(ah,'XLim',roi([1 3]),'YLim',roi([2 4]));
    for j=1:nbouts
        b = bout_idx{i}(j,:).*3;
        title(sprintf('Fly %i, Bout %i, L %i',i,j,diff(b)+1));
        frames = b(1)-padding_sz:b(2)+padding_sz;
        frames(frames<1) = [];
        for k=frames
            xlabel(sprintf('Frame: %d',double(k)-double(b(1))));
            lh.XData = flyTracks.centroid(k,1,i);
            lh.YData = flyTracks.centroid(k,2,i);
            if k>=b(1) && k<=b(2)
                lh.MarkerFaceColor = 'r';
            else
                lh.MarkerFaceColor = 'k';
            end
            drawnow
            pause(0.06);
        end
    end
end
