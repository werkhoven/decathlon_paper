

% bootstrap D1 and D2
D1_raw = D1;
D2_raw = D2;
D3_raw = D3;
% D1 = collapseMetrics(D1);
% D2 = collapseMetrics(D2);
% D3 = collapseMetrics(D3);

nReps = 100;
D1D2_r = NaN(nReps,1);
D1D3_r = NaN(nReps,1);
D2D3_r = NaN(nReps,1);
D1D1_r = NaN(nReps,1);
D2D2_r = NaN(nReps,1);
D3D3_r = NaN(nReps,1);

fprintf('\n');
for i=1:nReps
    
    fprintf('Iteration %i of %i\n',i,nReps)
    % D1-D2
    D1bs = D1;
    d1 = D1.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D2;
    d2 = D2.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [D1bs,D2bs] = pairFields(D1bs,D2bs,'Trim',true);
    [tmp,~] = corr_of_corrcoef(D1bs,D2bs,'Plot',false);
    D1D2_r(i) = tmp(1,2);
    
    % D1-D3
    D1bs = D1;
    d1 = D1.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D3;
    d2 = D3.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [D1bs,D2bs] = pairFields(D1bs,D2bs,'Trim',true);
    [tmp,~] = corr_of_corrcoef(D1bs,D2bs,'Plot',false);
    D1D3_r(i) = tmp(1,2);
    
    % D2-D3
    D1bs = D2;
    d1 = D2.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D3;
    d2 = D3.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [D1bs,D2bs] = pairFields(D1bs,D2bs,'Trim',true);
    [tmp,~] = corr_of_corrcoef(D1bs,D2bs,'Plot',false);
    D2D3_r(i) = tmp(1,2);

    % bootstrap D1 and D1
    D1bs = D1;
    d1 = D1.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D1;
    d2 = D1.data;
    D2_idx = randi(size(d1,1),[size(d1,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [D1bs,D2bs] = pairFields(D1bs,D2bs,'Trim',true);
    [tmp,~] = corr_of_corrcoef(D1bs,D2bs,'Plot',false);
    D1D1_r(i) = tmp(1,2);

    % bootstrap D2 and D2
    D1bs = D2;
    d1 = D2.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D2;
    d2 = D2.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [D1bs,D2bs] = pairFields(D1bs,D2bs,'Trim',true);
    [tmp,~] = corr_of_corrcoef(D1bs,D2bs,'Plot',false);
    D2D2_r(i) = tmp(1,2);
    
    % bootstrap D3 and D3
    D1bs = D3;
    d1 = D3.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D3;
    d2 = D3.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [D1bs,D2bs] = pairFields(D1bs,D2bs,'Trim',true);
    [tmp,~] = corr_of_corrcoef(D1bs,D2bs,'Plot',false);
    D3D3_r(i) = tmp(1,2);

end


%%

autoPlotDist(D1D2_r(:),true(size(D1D2_r(:))));
autoPlotDist(D1D3_r(:),true(size(D1D1_r(:))),gca);
autoPlotDist(D2D3_r(:),true(size(D2D2_r(:))),gca);
autoPlotDist(D1D1_r(:),true(size(D2D2_r(:))),gca);
autoPlotDist(D2D2_r(:),true(size(D2D2_r(:))),gca);
autoPlotDist(D3D3_r(:),true(size(D2D2_r(:))),gca);


set(gca,'XLim',[0 1],'YLim',[0 20]);
lbls = {'D3-D3';'D2-D2';'D1-D1';'D2-D3';'D1-D3';'D1-D2'};
legend(lbls,'Location','Northwest');
xlabel('correlation coefficient');
title('bootstrapped correlation of r-values')

