
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

figure('Name','correlation of decathlon r-values');
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
    subplot(2,2,i);
    bootstrap_decathlon_structs(D_col,50,mod(i,4)>0);
    title(sprintf('r-value bootstrap - %s filled (%s)',impute_mode,title_str));
end

