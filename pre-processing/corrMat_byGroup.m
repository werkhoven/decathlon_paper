function corrMat_byGroup(groups, D, fDir)

for i=1:numel(groups)
    
    [f, fidx] = groupFields(D.fields,groups{i});
    grp_mat = D.data(:,fidx);
    grp_label = groups{i};
    if iscell(grp_label)
        grp_label = grp_label{1};
    end
    plotCorr(grp_mat,'Labels',f,'SavePath',[fDir '\' grp_label],...
        'Title',grp_label);
end