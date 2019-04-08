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

% get the field names of each datase
f1 = A.fields;
f2 = B.fields;

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
B_sorted.data = B.data(:,permutation);
B_sorted.fields = f2(permutation);


