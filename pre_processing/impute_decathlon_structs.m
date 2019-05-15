function D = impute_decathlon_structs(D, varargin)
% impute each data struct separately using either regression of mean
% imputation


opts = parse_processing_options(varargin{:});
impute_mode = opts{find(strcmp(opts,'ImputeMode'))+1};
do_standardize = true;
if find(strcmpi(varargin,'Standardize'))
    do_standardize = varargin{find(strcmpi(varargin,'Standardize'))+1};
end

% standardize each metric
if do_standardize
    D = standardize_data_by_group(D);
    D = standardize_by_field(D);
end
imputed = cell(numel(D),1);

for i=1:numel(D)
    imputed{i} = isnan(D(i).data);
    if any(imputed{i}(:))
        switch impute_mode
            case 'mean'
                D(i).data(isnan(D(i).data)) = 0;
            case 'regression'
                D(i).data = fillWithRegressedValues(D(i).data);
            case 'knn'
                mean_filled = D(i).data;
                mean_filled(isnan(mean_filled)) = 0;
                knn_filled = D(i).data;
                for j=1:numel(D(i).fields)
                    tmp_data = mean_filled;
                    tmp_data(:,j) = D(i).data(:,j);
                    tmp_data = knnimpute(tmp_data', 40);
                    knn_filled(:,j) = tmp_data(j,:)';
                end
                D(i).data = knn_filled;
            case 'als'
                [coefs,score,~,~,~,mu] = pca(D(i).data,'algorithm','als');
                D(i).data = score*coefs' + mu;
            otherwise
                imputed{i} = false(size(D(i).data));
        end
    end
end

if any(~arrayfun(@(d) isreal(d.data), D))
    disp('stop');
end

for i=1:numel(imputed)
    if isfield(D(i),'imputed') && ~isempty(D(i).imputed)
        D(i).imputed = D(i).imputed | imputed{i};
    else
        D(i).imputed = imputed{i};
    end
end

