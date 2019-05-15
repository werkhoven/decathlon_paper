D_p = pair_decathlon_structs(D);

% cross-validate PCA for all apriori groups
nrow = 4;
ncol = 6;
for i=1:numel(D_p)
    figure;
    [apriori_data, apriori_names] = group_apriori_fields(D_p(i));
    for j=1:numel(apriori_data)
        subplot_offset = (ceil(j/ncol)-1)*ncol;
        subplot(nrow,ncol,j+subplot_offset);
         if size(apriori_data{j},2)>1
            cross_validate_pca(apriori_data{j},'KFolds',50,'TestSize',0.35);
        end
        title(sprintf('D%i - %s',i,apriori_names{j}));
        subplot(nrow,ncol,subplot_offset+j+ncol);
        if size(apriori_data{j},2)>1
            plot_pca_bootstrap(apriori_data{j},150,95,'noncummulative');
        end
        title(sprintf('D%i - %s, var explained',i,apriori_names{j}));
    end
end