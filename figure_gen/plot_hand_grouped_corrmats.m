%%

[D, als_data] = avg_als_impute(D, 100);

%% invert right bias

D_cat = [cat_decathlon_structs(D_als(1:2)) D_als(3)];

for i=1:numel(D)
    [~,p] = groupFields(standardize_fieldnames(D(i).fields), 'right_bias');
    D(i).data(:,p) = D(i).data(:,p).*-1;
end

%%
groups = [{'Circadian speed';'Circadian nBouts';'Circadian bout_length';'Circadian bout_clumpiness';...
    'Circadian gravitactic';'Circadian circling'};...
    {{'speed'}};{{'nTrials'}};...
    {{'nBouts'}};{{'bout_length'}};{{'bout_clumpiness'}};...
    {{'circling'}};{{'right_bias'}};...
    {{'clumpiness';'iti'}};...
    {'switchiness'};...
    {{'light_bias';'Phototaxis occupancy'}};...
    {'optomotor_index';'Olfaction occupancy';'Olfaction preodor_occupancy'}];

collapse_fields = 'all';
collapse_mode = 'PCA';
D_p = remove_keyword_fields(D,'','KeywordGroup','none');
D_p = collapseMetrics(D_p,'CollapseMode',collapse_mode,'CollapseFields',collapse_fields,'PCs',2);
permutations = cell(numel(D),1);
if ~strcmpi(collapse_fields,'all')
    for i=1:numel(D)
        idx = [];
        for j=1:numel(groups)
            [tmp_fields, p] = groupFields(standardize_fieldnames(D_p(i).fields), groups{j});
            [assay,metric,day] = parse_fieldnames(tmp_fields);
            if ~isempty(assay) && ~isempty(metric)
                new_fields = cellfun(@(a,m) sprintf('%s %s',a,m), assay, metric,...
                    'UniformOutput', false);
                [~,pp] = sort(new_fields);
                new_idx = p(pp);
                idx = [idx new_idx(~ismember(new_idx,idx))];
            end
        end
        permutations{i} = idx;
        D_p(i) = apply_cluster_permutation(idx,D_p(i));
    end
end


%
for i=1:numel(D_p)
    fh=plotCorr(D_p(i).data,'Labels',D_p(i).fields,'Cluster',false,'Patch',false);
    figure(fh(1));
    axis(gca,'equal','tight');
end