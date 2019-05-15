function [A_sorted,B_sorted] = pairFields(A,B,varargin)
% Sort and match fields between decathlon data structures A and B

trim=false;
for i=1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Trim'
                i=i+1;
                trim = varargin{i};
        end
    end
end

% get the field names of each dataset
f1 = standardize_fieldnames(A.fields);
f2 = standardize_fieldnames(B.fields);

if trim
    % remove day of testing information from non-circadian measures
    af1 = find(cellfun(@isempty,strfind(f1,'Circadian')));
    trimmed = cellfun(@(x,y) x(1:y-2),f1(af1),strfind(f1(af1),'('),'UniformOutput',false);
    f1(af1(~cellfun(@isempty,trimmed))) = trimmed(~cellfun(@isempty,trimmed));
    af2 = find(cellfun(@isempty,strfind(f2,'Circadian')));
    trimmed = cellfun(@(x,y) x(1:y-2),f2(af2),strfind(f2(af2),'('),'UniformOutput',false);
    f2(af2(~cellfun(@isempty,trimmed))) = trimmed(~cellfun(@isempty,trimmed));
end

% get mapping between datasets A and B
permutation = cellfun(@(x) find(strcmpi(x,f2(:)),1,'Last'),f1,'UniformOutput',false);
idxA = 1:length(f1);
idxA(cellfun(@isempty,permutation))=[];
permutation(cellfun(@isempty,permutation))=[];
permutation = cat(1,permutation{:});

% permute data and fields
A_sorted.data = A.data(:,idxA);
A_sorted.fields = f1(idxA);
A_sorted.n = get_pairwise_sampling(A_sorted.data);
meta_f  = fieldnames(A.meta);
for i=1:numel(meta_f)
    A_sorted.meta.(meta_f{i}) = A.meta.(meta_f{i})(:,idxA);
end
if isfield(A,'imputed')
   A_sorted.imputed = A.imputed(:,idxA); 
end

B_sorted.data = B.data(:,permutation);
B_sorted.fields = f2(permutation);
B_sorted.n = get_pairwise_sampling(B_sorted.data);
meta_f  = fieldnames(B.meta);
for i=1:numel(meta_f)
    B_sorted.meta.(meta_f{i}) = B.meta.(meta_f{i})(:,permutation);
end
if isfield(B,'imputed')
   B_sorted.imputed = B.imputed(:,permutation); 
end

