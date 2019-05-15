
d = [];
f = {'Olfaction preodor_occupancy';'Olfaction occupancy'};
D_p = pair_decathlon_structs(D,'ImputeMode','none','Standardize',false);
D_p = impute_decathlon_structs(D_p,'ImputeMode','none','Standardize',false);
for i=1:numel(D)
    ff = standardize_fieldnames(D_p(i).fields);
    idx = [find(any(str_list_contains(ff,f{1}),2)) find(any(str_list_contains(ff,f{2}),2))];
    d = [d; D_p(i).data(:,idx)];
end

hold on;
pretty_scatter(d(:,1),d(:,2),'k','MarkerSize',3);
xlabel('preodor occupancy');
ylabel('odor occupancy');

scatter_field_pairs(D_p,idx)
ah = findall(gcf,'Type','axes');
for i=1:numel(ah)
    set(ah(i),'XLim',[0 1],'YLim',[0 1],'XTick',0:.2:1,'YTick',0:0.2:1);
    xlabel(ah(i),'pre-odor occupancy');
    ylabel(ah(i),'odor occupancy');
end

nanmean(D_p(1).data(:,idx))
nanmean(D_p(2).data(:,idx))
nanmean(D_p(3).data(:,idx))

%%

save_dir = 'D:\decathlon_data_and_analysis\decathlon_analysis\figures\olfaction_troubleshooting\mbockplots\';
fdir = autoDir;
fpaths = recursiveSearch(fdir,'keyword','processed');

for i=1:numel(fpaths)
    load(fpaths{i});
    [~,name] = fileparts(fpaths{i});
    MbockPlot2014(flyTracks);
    ahs = findall(gcf,'Type','axes');
    pos = get(ahs,'Position');
    pos = cat(1,pos{:});
    [~,p] = sort(pos(:,1));
    pos = pos(p,:);
    ahs = ahs(p);
    pos(1,:) = [];
    ahs(1) = [];
    for j=1:numel(flyTracks.occupancy)
        hold(ahs(j),'on');
        text(sum(pos(j,[1 3]).*[1 0.5]),-30,sprintf('occ = %0.2f',flyTracks.occupancy(j)),...
        'Parent',ahs(j),'HorizontalAlignment','left');
    end
    savefig(gcf,sprintf('%smbockplot_%s.fig',save_dir,name));
    close(gcf);
end
