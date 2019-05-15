function var_explained = plot_pca_bootstrap(data,nreps,ci,mode)

% bootstrap PCA null model by shuffling data matrix and performing PCA
[~, ~, var_explained] = bootstrap_pca_nullmodel(data,nreps);
[null_ph, null_lh] = plot_model(var_explained,'r',ci,mode);

% bootstrap PCA null model by shuffling data matrix and performing PCA
[~, ~, var_explained] = bootstrap_pca_observed(data,nreps);
[obs_ph, obs_lh] = plot_model(var_explained,'k',ci,mode);

% configure plot labels
leg_labels = {'observed mean';'shuffled mean';'observed CI95%';'shuffled CI95%'};
switch mode
    case 'cummulative'
        ylabel({'cummulative';'variance explained'});
        xlabel('num PCs included');
        legend([obs_lh,null_lh,obs_ph,null_ph],leg_labels,'Location','SouthEast');
    otherwise
        ylabel('variance explained');
        xlabel('PC number');
        legend([obs_lh,null_lh,obs_ph,null_ph],leg_labels,'Location','NorthEast');
end



function [ph, lh] = plot_model(var_exp,color,ci,mode)

% compute var explained mean and confidence interval
var_exp = cat(2,var_exp{:});
switch mode
    case 'cummulative'
        var_exp = cumsum(var_exp);
        ylim = 100;
    otherwise
        ylim = ceil(max(var_exp(:))*1.1);
end
        
ci95 = NaN(size(var_exp,1),2);
ci95(:,1) = prctile(var_exp,(100-ci)/2,2);
ci95(:,2) = prctile(var_exp,100-(100-ci)/2,2);
var_exp = nanmean(var_exp,2);

% plot mean and CI
hold on;
npcs = numel(var_exp);
vx = [1 1:npcs npcs:-1:1];
vy = [ci95(1,2) ci95(:,1)' fliplr(ci95(:,2)')];
ph = patch('XData',vx(:),'YData',vy(:),'FaceColor',color,'FaceAlpha',0.2,...
    'EdgeColor','none','LineWidth',0.5);
lh = plot(1:npcs,var_exp,'Color',color,'LineStyle','-','LineWidth',1);
set(gca,'XLim',[1 npcs],'YLim',[0 ylim]);