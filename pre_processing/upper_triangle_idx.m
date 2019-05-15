function idx = upper_triangle_idx(dim)

L=1:dim;
subs = arrayfun(@(x) [L(L<x)' repmat(x,sum(L<x),1)],L,'UniformOutput',false);
subs = cat(1,subs{:});
idx = sub2ind([L(end) L(end)],subs(:,1),subs(:,2));