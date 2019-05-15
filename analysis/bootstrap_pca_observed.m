function [eigvecs, eigvals, var_explained] = bootstrap_pca_observed(data,nreps)

warning('off','stats:pca:ColRankDefX');

% check that matrix is complete
if any(isnan(data(:)))
    error('Cannot perform PCA. Matrix contains missing values.');
end

eigvecs = cell(nreps,1);
eigvals = cell(nreps,1);
var_explained = cell(nreps,1);
for i=1:nreps
    resampled_data = data(randi(size(data,1),[size(data,1) 1]),:);
    [eigvecs{i}, ~, eigvals{i}, ~, var_explained{i}] = pca(resampled_data);
end