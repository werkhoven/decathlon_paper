function [train_mse, test_mse, pca_results, batch_data] = cross_validate_pca(data,varargin)
% perform cross validation of PCA and plot train/test error

% define default params
test_size = 0.2;
k_folds = 5;
do_plot = true;

for i=1:numel(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'TestSize'
                i=i+1;
                test_size = varargin{i};
            case 'KFolds'
                i=i+1;
                k_folds = varargin{i};
            case 'Plot'
                i=i+1;
                do_plot = varargin{i};
        end
    end
end


[n,k] = size(data);
masks = false([n k k_folds]);
L = NaN([n k k_folds]);
R = NaN([k k k_folds]);
mu = NaN(k_folds,k);

fprintf('\n');
for i=1:k_folds
    fprintf('K-Fold %i of %i\n',i,k_folds);
    masks(:,:,i) = rand(size(data)) > test_size;
    [L(:,:,i),R(:,:,i),mu(i,:)] = censored_least_squares(data, masks(:,:,i));
end

% iterate over values of k
train_mse = NaN(k,k_folds);
test_mse = NaN(k,k_folds);
for i=1:k
    for j=1:k_folds 
        residuals = nanzscore(L(:,1:i,j)*R(:,1:i,j)') - data;
        train_mse(i,j) = mean(residuals(masks(:,:,j)).^2);
        test_mse(i,j) = mean(residuals(~masks(:,:,j)).^2);
    end
end

opts = {'Marker'; 'o'; 'LineStyle'; 'none'; 'MarkerEdgeColor'; 'none';...
        'MarkerSize'; 2; 'LineWidth'; 2};
hold on;
lh_train = plot(1:k,mean(train_mse,2),'MarkerFaceColor','k',opts{:});
lh_test =  plot(1:k,mean(test_mse,2),'MarkerFaceColor','r',opts{:});
xlabel('PC no.');
ylabel('MSE');
title(sprintf('PCA Cross-validated MSE (k=%i folds)',k_folds));
legend([lh_train lh_test],{'training error';'test error'},'FontSize',6);
drawnow; pause(0.1);
set(gca,'XLim',[0 k+1],'YLim',[0 max(mean(test_mse,2))*1.5]);


function [L,R,mu] = censored_least_squares(D, M)
% Least squares of M * (AX - B) over X, where M is a masking matrix.

% rhs = dot(A', M.*B)';
% T = A' M.*A;
opts = statset('pca');
D(~M) = NaN;
%[L,R,mu] = dec_als(D,size(D,2),'Orthonormal',true,'Centered',true,'Options',opts);
[R,L,~,~,~,mu] = pca(D,'algorithm','als');


