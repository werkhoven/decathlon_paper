figure;
PCs=5;

%% plot correlation between raw data
subplot(4,3,1);
[D1_p,D2_p] = pairFields(D1,D2,'Trim',true);
corr_of_corrcoef(D1_p,D2_p,'Title','D1-D2 (raw)','Plot',true);
subplot(4,3,2);
[D1_p,D3_p] = pairFields(D1,D3,'Trim',true);
corr_of_corrcoef(D1_p,D3_p,'Title','D1-D3 (raw)','Plot',true);
subplot(4,3,3);
[D2_p,D3_p] = pairFields(D2,D3,'Trim',true);
corr_of_corrcoef(D2_p,D3_p,'Title','D2-D3 (raw)','Plot',true);

%% plot correlation after circadian metric collapse

D1col = collapseMetrics(D1);
D2col = collapseMetrics(D2);
D3col = collapseMetrics(D3);
subplot(4,3,4);
[D1_p,D2_p] = pairFields(D1col,D2col,'Trim',true);
corr_of_corrcoef(D1_p,D2_p,'Title','D1-D2 (circ collapsed)','Plot',true);
subplot(4,3,5);
[D1_p,D3_p] = pairFields(D1col,D3col,'Trim',true);
corr_of_corrcoef(D1_p,D3_p,'Title','D1-D3 (circ collapsed)','Plot',true);
subplot(4,3,6);
[D2_p,D3_p] = pairFields(D2col,D3col,'Trim',true);
corr_of_corrcoef(D2_p,D3_p,'Title','D2-D3 (circ collapsed)','Plot',true);


%% plot correlation after all apriori collapse

D1col = collapseMetrics(D1,'Fields','all');
D2col = collapseMetrics(D2,'Fields','all');
D3col = collapseMetrics(D3,'Fields','all');
subplot(4,3,7);
[D1_p,D2_p] = pairFields(D1col,D2col,'Trim',true);
corr_of_corrcoef(D1_p,D2_p,'Title','D1-D2 (all collapsed)','Plot',true);
subplot(4,3,8);
[D1_p,D3_p] = pairFields(D1col,D3col,'Trim',true);
corr_of_corrcoef(D1_p,D3_p,'Title','D1-D3 (all collapsed)','Plot',true);
subplot(4,3,9);
[D2_p,D3_p] = pairFields(D2col,D3col,'Trim',true);
corr_of_corrcoef(D2_p,D3_p,'Title','D2-D3 (circ collapsed)','Plot',true);


%%

D1col = collapseMetrics(D1,'Fields','all','Mode','PCA','PCs',PCs);
D2col = collapseMetrics(D2,'Fields','all','Mode','PCA','PCs',PCs);
D3col = collapseMetrics(D3,'Fields','all','Mode','PCA','PCs',PCs);
subplot(4,3,10);
[D1_p,D2_p] = pairFields(D1col,D2col,'Trim',true);
corr_of_corrcoef(D1_p,D2_p,'Title','D1-D2 (PCA)','Plot',true);
subplot(4,3,11);
[D1_p,D3_p] = pairFields(D1col,D3col,'Trim',true);
corr_of_corrcoef(D1_p,D3_p,'Title','D1-D3 (PCA)','Plot',true);
subplot(4,3,12);
[D2_p,D3_p] = pairFields(D2col,D3col,'Trim',true);
corr_of_corrcoef(D2_p,D3_p,'Title','D2-D3 (PCA)','Plot',true);

