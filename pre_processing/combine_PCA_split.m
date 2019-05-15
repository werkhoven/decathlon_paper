function D = combine_PCA_split(D,varargin)
% combines the data from the array of decathlon structs (D), performs PCA
% on the combined data, and splits the data back apart

opts = parse_processing_options(varargin{:});

% match fields between decathlon structs
for i=1:numel(D)
    for j=1:numel(D)-1
        other_idx = find(~ismember(1:numel(D),i));
        [D(i),D(other_idx(j))] = pairFields(D(i),D(other_idx(j)),...
            'Trim',true);
    end
end

D_comb = struct('data',[],'fields',[],'batch',[]);
is_incomplete = arrayfun(@(d) any(isnan(d.data(:))), D);
if any(is_incomplete)
    warning('data is incomplete, imputing by ALS averaging');
    for i=1:numel(D)
        if is_incomplete(i)
            D(i) = avg_als_impute(D(i),50);
        end
    end
end
complete_data = arrayfun(@(d) d.data, D, 'UniformOutput', false);
D_comb.data = cat(1,complete_data{:});
D_comb.fields = D(1).fields;
D_comb.batch = arrayfun(@(i) repmat(i,size(D(i).data,1),1), 1:numel(D),...
    'UniformOutput', false);
D_comb.batch = cat(1,D_comb.batch{:});


% mean impute the data
D_comb = collapseMetrics(D_comb,opts{:});

for i=1:numel(D)
    D(i).data = D_comb.data(D_comb.batch==i,:);
    D(i).fields = D_comb.fields;
end