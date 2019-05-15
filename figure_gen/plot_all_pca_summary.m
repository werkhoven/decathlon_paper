
% load data
load(['D:\decathlon_data_and_analysis\decathlon_analysis\matrices\',...
    'decathlon_paper\nuisance unregressed\D123_olfaction_timeofday_added.mat']);

% define params
impute_mode = 'als';
k_folds = 50;

% pre-process data
D = impute_decathlon_structs(D,'ImputeMode',impute_mode);
D = standardize_by_field(D);


%%
figure('Name','PCA cross-validation');
pca_results = cell(4,numel(D));
for i=1:4
    switch i
        case 1
            collapse_mode = 'average';
            collapse_fields = 'none';
            title_str = 'circ expanded';
        case 2
            collapse_mode = 'average';
            collapse_fields = 'circadian';
            title_str = 'circ collapsed';
        case 3
            collapse_mode = 'average';
            collapse_fields = 'all';
            title_str = 'a priori collapsed';
        case 4
            collapse_mode = 'PCA';
            collapse_fields = 'all';
            title_str = 'a priori PCA';
    end
    opts = {'CollapseFields';collapse_fields;'CollapseMode';collapse_mode;...
        'PCs';2;'Trim';true};
    D_col = collapseMetrics(D,opts{:});
    for j=1:numel(D_col)
        subplot(4,numel(D_col),(i-1)*numel(D_col)+j);
        cross_validate_pca(D_col(j).data,'KFolds',k_folds,'TestSize',0.25);
        title(sprintf('D%i - %s filled (%s)',j,impute_mode,title_str)); 
    end
end

