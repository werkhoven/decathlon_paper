function scatter_field_pairs(D, pair_idx)
% scatter pairs of fields vs each other

% calculate num row/col for subplots
n_pairs = size(pair_idx,1)*numel(D);
nCol = ceil(sqrt(n_pairs));
nCol(nCol>8) = 8;
while mod(nCol,numel(D)) ~= 0
    nCol = nCol + 1;
end
nRows = ceil(n_pairs/nCol);
nRows(nRows>8) = 8;


% initialize plot options
opts = {'Marker'; 'o'; 'LineStyle'; 'none';...
    'MarkerEdgeColor'; 'none';'MarkerSize'; 1.5; 'LineWidth'; 1};
fopts = {'FontSize',6,'FontWeight','normal'};
[assay,metric] = parse_fieldnames(D(1).fields);
metric = pretty_labels(metric);
if numel(assay) ~= numel(metric)
    labels = D(1).fields;
else
    labels = cellfun(@(a,m) {a;m}, assay, metric, 'UniformOutput', false);
end

for j=1:size(pair_idx,1)
    for i=1:numel(D)
        
        plot_num = (j-1)*numel(D) + i-1;
        subplot_num = mod(plot_num,nCol*nRows);
        if subplot_num == 0
            figure;
        end
    
        ah = subplot(nRows,nCol,subplot_num+1);

        % fit model
        x = D(i).data(:,pair_idx(j,1));
        y = D(i).data(:,pair_idx(j,2));
        x_miss = D(i).imputed(:,pair_idx(j,1));
        y_miss = D(i).imputed(:,pair_idx(j,2));
        mask = ~isnan(x) & ~isnan(y);
        x = x(mask);
        y = y(mask);
        x_miss = x_miss(mask);
        y_miss = y_miss(mask);

        mdl = PCARegressionCI([x y],[x_miss y_miss], ah);
        drawnow limitrate
        set(ah,'XTick',[],'YTick',[],'Clipping','on');
        xlabel(labels{pair_idx(j,1)}, fopts{:});
        ylabel(labels{pair_idx(j,2)}, fopts{:});
        title(sprintf('D%i - rank %i',i,j),fopts{:});
    end
end