function D = collapseMetrics(D,varargin)



% parse inputs
mode = 'average';
fields = 'circadian';
PCs = 2;
grp_path = 'D:\decathlon_data_and_analysis\decathlon 8-2017\meta\apriori_groups.mat';
for i=1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'CollapseMode'
                i=i+1;
                mode = varargin{i};
            case 'CollapseFields'
                i=i+1;
                fields = varargin{i};
            case 'PCs'
                i=i+1;
                PCs = varargin{i};
        end
    end
end

% iterate recursively if more than one element
if numel(D)>1
    if strcmpi(mode,'PCA')
        D = combine_PCA_split(D,varargin{:});
    else
        for i=1:numel(D)
            D(i) = collapseMetrics(D(i),varargin{:});
        end
    end
    return
end

f = D.fields;
    


switch lower(fields)
    case 'circadian'
        
        % find relevant indices in the matrix
        idx = find(~cellfun(@isempty,strfind(f,'Circadian')));
        cf = f(idx);
        cf = cellfun(@(x,y) x(1:y-2),cf,strfind(cf,'('),'UniformOutput',false);
        cf = cellfun(@(x,y) x(y+10:end),cf,strfind(cf,'Circadian'),'UniformOutput',false);
        
        % get unique field names and compute average
        uf = unique(cf);
        ufilt = cellfun(@(x) strcmp(cf,x),uf,'UniformOutput',false);
        collapsed = cellfun(@(x) nanmean(D.data(:,idx(x)),2),ufilt,'UniformOutput',false);
        newFields = cellfun(@(x) ['Circadian ' x],uf,'UniformOutput',false);
        
        % remove raw data and old field names
        D.data(:,idx)=[];
        D.fields(idx)=[];
        D.data = [D.data cat(2,collapsed{:})];
        D.fields = [D.fields; newFields];      
        
    case 'all'
        
        [apriori_data, apriori_names] = group_apriori_fields(D);
        
        for i=1:length(unique(apriori_names))
            if ~isempty(apriori_data{i})
                switch mode
                    case 'average'
                        collapsed_data = cellfun(@(ad) nanmean(ad,2), ...
                                    apriori_data, 'UniformOutput', false);
                        dMat = cat(2,collapsed_data{:});
                        nf = apriori_names;
                    case 'PCA'
                        [coef,score,lat,~,explained] = ...
                            cellfun(@pca,apriori_data,'UniformOutput',false);

                        % determine number of PCs to keep
                        npcs = cellfun(@(sc) size(sc,2), score);
                        if isscalar(PCs)
                            npcs(npcs>PCs) = PCs;
                        else
                            npcs(npcs>PCs) = PCs(npcs>PCs);
                        end
                        pc_data = cellfun(@(sc,n) sc(:,1:n), score, ...
                                    num2cell(npcs),'UniformOutput', false);
                        %dMat = nanzscore(cat(2,pc_data{:}));
                        dMat = cat(2,pc_data{:});
                        % create new field names
                        nf = cell(sum(npcs),1);
                        j = 0;
                        for i=1:numel(apriori_names)
                            nf(j+1:j+npcs(i)) = arrayfun(@(ii) ...
                                sprintf('%s (PC%i)',apriori_names{i},ii),...
                                1:npcs(i), 'UniformOutput', false);
                            j = j+npcs(i);
                        end
                end
            end
        end
        
        D.data = dMat;
        D.fields = nf;
end

