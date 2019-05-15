%% iterate over Kyobi's autoTrackerV2 Y-Maze data and process

save_dir = uigetdir('Select a save directory');
fdir = autoDir;
fpaths = recursiveSearch(fdir,'ext','.mat','keyword','_screen');

fprintf('\n');
for i=1:numel(fpaths)

    % load and process data
    fprintf('processing file %i of %i\n',i,numel(fpaths));
    load(fpaths{i},'flyTracks');
    turn_data = parse_v2_ymaze_data(flyTracks);

    % save processed data
    [~,fname] = fileparts(fpaths{i});
    save(sprintf('%s/%s_reprocessed.mat',save_dir,fname),'turn_data');
    clear flyTracks turn_data
end


%% iterate over Kyobi's autoTrackerV2 Y-Maze data and process by light status

save_dir = uigetdir('Select a save directory');
fdir = autoDir;
fpaths = recursiveSearch(fdir,'ext','.mat','keyword','_screen');

fprintf('\n');
for i=1:numel(fpaths)

    % load and process data
    fprintf('processing file %i of %i\n',i,numel(fpaths));
    load(fpaths{i},'flyTracks');
    [turn_data,fig_handle] = parse_v2_by_lightstatus(flyTracks);

    % save processed data
    [~,fname] = fileparts(fpaths{i});
    save(sprintf('%s/%s_reprocessed.mat',save_dir,fname),'turn_data');
    savefig(fig_handle,sprintf('%s/%s_bout_parse.fig',save_dir,fname));
    close(fig_handle);
    clear flyTracks turn_data
end

%%

% get reprocessed file paths
fpaths = recursiveSearch(save_dir,'keyword','reprocessed');

% initalize placeholders
split_gal4.gen_bg = cell(numel(fpaths),1);
split_gal4.effector = cell(numel(fpaths),1);
split_gal4.clumpiness.data = cell(numel(fpaths),1);
split_gal4.clumpiness.n = cell(numel(fpaths),1);
split_gal4.switchiness.data = cell(numel(fpaths),1);
split_gal4.switchiness.n = cell(numel(fpaths),1);
split_gal4.speed.data = cell(numel(fpaths),1);
split_gal4.bouts.data = cell(numel(fpaths),1);

fprintf('\n');
for i=1:numel(fpaths)
    fprintf('loading file %i of %i\n',i,numel(fpaths));
    load(fpaths{i});
    
    % assign strain and effector data
    strain = turn_data.labels.Strain{1};
    split_gal4.gen_bg(i) = regexp(strain,'SS[0-9]*(?=_)','match');
    split_gal4.effector(i) = regexp(strain,'(?<=_)\w*','match');
    
    % assign clumpiness and switchiness data
    split_gal4.clumpiness.data{i} = nanzscore(turn_data.clumpiness.data')';
    split_gal4.clumpiness.n{i} = turn_data.clumpiness.n;
    split_gal4.switchiness.data{i} = nanzscore(turn_data.switchiness.data')';
    split_gal4.switchiness.n{i} = turn_data.switchiness.n;
    split_gal4.speed.data{i} = nanzscore(turn_data.speed.avg)';
    split_gal4.bouts.data{i} = nanzscore(turn_data.bouts.clumpiness)';
end

% sort data by gal4 line and effector
[~,p_gen_bg] = sort(split_gal4.gen_bg);
split_gal4.gen_bg = split_gal4.gen_bg(p_gen_bg);
split_gal4.effector = split_gal4.effector(p_gen_bg);
split_gal4.clumpiness.data = split_gal4.clumpiness.data(p_gen_bg);
split_gal4.clumpiness.n = split_gal4.clumpiness.n(p_gen_bg);
split_gal4.switchiness.data = split_gal4.switchiness.data(p_gen_bg);
split_gal4.switchiness.n = split_gal4.switchiness.n(p_gen_bg);
split_gal4.speed.data = split_gal4.speed.data(p_gen_bg);
split_gal4.bouts.data = split_gal4.bouts.data(p_gen_bg);

% now sort each unique gal4 for line by each effector
unique_bgs = unique(split_gal4.gen_bg);
dat_struct = struct('data',[],'n',[]);
ldm_screen = struct('gal4',[],'effector',[],'clumpiness',dat_struct,...
    'switchiness',dat_struct,'speed',dat_struct,'bouts',dat_struct);
for i=1:numel(unique_bgs)
    % find permutation by genotype
    bg_idx = find(strcmpi(split_gal4.gen_bg,unique_bgs{i})); 
    [~,p_effector] = sort(split_gal4.effector(bg_idx));
    
    % grab data from the current strain sorted by effector
    unique_eff = unique(split_gal4.effector(bg_idx));
    bg_idx = bg_idx(p_effector);
    effectors = split_gal4.effector(bg_idx);
    clump_dat = split_gal4.clumpiness.data(bg_idx);
    clump_n = split_gal4.clumpiness.n(bg_idx);
    switch_dat = split_gal4.switchiness.data(bg_idx);
    switch_n = split_gal4.switchiness.n(bg_idx);
    speed_dat = split_gal4.speed.data(bg_idx);
    bout_dat = split_gal4.bouts.data(bg_idx);
    
    for j=1:numel(unique_eff)
        eff_idx = find(strcmpi(effectors,unique_eff{j}));
        ldm_screen.gal4 = [ldm_screen.gal4; unique_bgs(i)];
        ldm_screen.effector = [ldm_screen.effector; unique_eff(j)];
        ldm_screen.clumpiness.data = [ldm_screen.clumpiness.data; {cat(2,clump_dat{eff_idx})}];
        ldm_screen.clumpiness.n = [ldm_screen.clumpiness.n; {cat(2,clump_n{eff_idx})}];
        ldm_screen.switchiness.data = [ldm_screen.switchiness.data; {cat(2,switch_dat{eff_idx})}];
        ldm_screen.switchiness.n = [ldm_screen.switchiness.n; {cat(2,switch_n{eff_idx})}];
        ldm_screen.speed.data = [ldm_screen.speed.data; {cat(1,speed_dat{eff_idx})'}];
        ldm_screen.bouts.data = [ldm_screen.bouts.data; {cat(1,bout_dat{eff_idx})'}];
    end
end


%% create bar plot of all lines for each effector

unique_effs = unique(ldm_screen.effector);
unique_effs = unique_effs([2 1 3]);
unique_bgs = unique(ldm_screen.gal4);
bar_width = 0.125;
bar_centers = 0:numel(unique_bgs)-1;
vx = cell(6,1);
vy_clump = cell(6,1);
vy_switch = cell(6,1);
vy_rval = cell(6,1);
vy_speed = cell(6,1);
vy_bout = cell(6,1);
ci_x = NaN(3,numel(unique_bgs)*6);
ci_clump = NaN(3,numel(unique_bgs)*6);
ci_switch = NaN(3,numel(unique_bgs)*6);
ci_bout = NaN(3,numel(unique_bgs)*6);
ci_speed = NaN(3,numel(unique_bgs)*6);
ldm_screen.clumpiness.mean_23C = cell(numel(ldm_screen.gal4),1);
ldm_screen.clumpiness.mean_33C = cell(numel(ldm_screen.gal4),1);
ldm_screen.switchiness.mean_23C = cell(numel(ldm_screen.gal4),1);
ldm_screen.switchiness.mean_33C = cell(numel(ldm_screen.gal4),1);
ldm_screen.bouts.mean_23C = cell(numel(ldm_screen.gal4),1);
ldm_screen.bouts.mean_33C = cell(numel(ldm_screen.gal4),1);
ldm_screen.speed.mean_23C = cell(numel(ldm_screen.gal4),1);
ldm_screen.speed.mean_33C = cell(numel(ldm_screen.gal4),1);
ldm_screen.rvals = cell(numel(ldm_screen.gal4),1);

ct = 0;
for i=1:numel(unique_bgs)
    bg_idx = find(strcmpi(ldm_screen.gal4,unique_bgs{i}));
    tmp_effs = ldm_screen.effector(bg_idx);
    for j=1:numel(unique_effs)
        ct = ct+1;
        eff_idx = find(strcmpi(tmp_effs,unique_effs{j}));
        patch_idx = (j-1)*2 + [1 2];
        if isempty(eff_idx)
            vx{patch_idx(1)} = [vx{patch_idx(1)} NaN(5,1)];
            vx{patch_idx(2)} = [vx{patch_idx(2)} NaN(5,1)];
            vy_clump{patch_idx(1)} = [vy_clump{patch_idx(1)} NaN(5,1)];
            vy_clump{patch_idx(2)} = [vy_clump{patch_idx(2)} NaN(5,1)];
            vy_switch{patch_idx(1)} = [vy_switch{patch_idx(1)} NaN(5,1)];
            vy_switch{patch_idx(2)} = [vy_switch{patch_idx(2)} NaN(5,1)];
            vy_rval{patch_idx(1)} = [vy_rval{patch_idx(1)} NaN(5,1)];
            vy_rval{patch_idx(2)} = [vy_rval{patch_idx(2)} NaN(5,1)];
            vy_speed{patch_idx(1)} = [vy_speed{patch_idx(1)} NaN(5,1)];
            vy_speed{patch_idx(2)} = [vy_speed{patch_idx(2)} NaN(5,1)];
            vy_bout{patch_idx(1)} = [vy_bout{patch_idx(1)} NaN(5,1)];
            vy_bout{patch_idx(2)} = [vy_bout{patch_idx(2)} NaN(5,1)];
        else
            % index into data
            eff_idx = bg_idx(eff_idx);
            clump_dat = ldm_screen.clumpiness.data{eff_idx}([1 2 5 6],:);
            clump_n = ldm_screen.clumpiness.n{eff_idx}([1 2 5 6],:);
            switch_dat = ldm_screen.switchiness.data{eff_idx}([1 2 5 6],:);
            switch_n = ldm_screen.switchiness.n{eff_idx}([1 2 5 6],:);
            bout_dat = ldm_screen.bouts.data{eff_idx}([1 3],:);
            speed_dat = ldm_screen.speed.data{eff_idx}([1 3],:);
            
%             % zscore data
%             clump_dat = nanzscore(clump_dat')';
%             switch_dat = nanzscore(switch_dat')';
%             bout_dat = nanzscore(bout_dat')';
%             speed_dat = nanzscore(speed_dat')';
           
            % compute weighted average of light and dark conditions
            y_clump_23C = nansum((clump_n(1:2,:)./nansum(clump_n(1:2,:))).*clump_dat(1:2,:));
            y_switch_23C = nansum((switch_n(1:2,:)./nansum(switch_n(1:2,:))).*switch_dat(1:2,:));
            y_clump_33C = nansum((clump_n(3:4,:)./nansum(clump_n(3:4,:))).*clump_dat(3:4,:));
            y_switch_33C = nansum((switch_n(3:4,:)./nansum(switch_n(3:4,:))).*switch_dat(3:4,:));
            y_bout_23C = bout_dat(1,:);
            y_bout_33C = bout_dat(2,:);
            y_speed_23C = speed_dat(1,:);
            y_speed_33C = speed_dat(2,:);
            ldm_screen.clumpiness.mean_23C{eff_idx} = y_clump_23C;
            ldm_screen.clumpiness.mean_33C{eff_idx} = y_clump_33C;
            ldm_screen.switchiness.mean_23C{eff_idx} = y_switch_23C;
            ldm_screen.switchiness.mean_33C{eff_idx} = y_switch_33C;
            ldm_screen.bout.mean_23C{eff_idx} = y_bout_23C;
            ldm_screen.bout.mean_33C{eff_idx} = y_bout_33C;
            ldm_screen.speed.mean_23C{eff_idx} = y_speed_23C;
            ldm_screen.speed.mean_33C{eff_idx} = y_speed_33C;
            
            % compute confidence intervals
            ci_idx = (i-1)*6+(j-1)*2;
            cis = bootstrap_mean_CI([y_clump_23C' y_clump_33C'],0.05,100);
            ci_clump(1:2,ci_idx+[1 2]) = cis';
            cis = bootstrap_mean_CI([y_switch_23C' y_switch_33C'],0.05,100);
            ci_switch(1:2,ci_idx+[1 2]) = cis';
            cis = bootstrap_mean_CI([y_bout_23C' y_bout_33C'],0.05,100);
            ci_bout(1:2,ci_idx+[1 2]) = cis';
            cis = bootstrap_mean_CI([y_speed_23C' y_speed_33C'],0.05,100);
            ci_speed(1:2,ci_idx+[1 2]) = cis';
            
            % update patch x-vectors
            x = bar_centers(i)+j*bar_width*2 - bar_width*1.5;
            ci_x(1:2,ci_idx+[1 2]) = repmat(x+bar_width.*[.5 1.5],2,1);
            vx{patch_idx(1)} = [vx{patch_idx(1)} [x; x; x+bar_width; x+bar_width; x]];
            x = bar_centers(i)+j*bar_width*2 - bar_width*0.5;
            vx{patch_idx(2)} = [vx{patch_idx(2)} [x; x; x+bar_width; x+bar_width; x]];
            
            % update patch y-vectors
            y = nanmean(y_clump_23C);
            vy_clump{patch_idx(1)} = [vy_clump{patch_idx(1)} [y; 0; 0; y; y]];
            y = nanmean(y_clump_33C);
            vy_clump{patch_idx(2)} = [vy_clump{patch_idx(2)} [y; 0; 0; y; y]];
            y = nanmean(y_switch_23C);
            vy_switch{patch_idx(1)} = [vy_switch{patch_idx(1)} [y; 0; 0; y; y]];
            y = nanmean(y_switch_33C);
            vy_switch{patch_idx(2)} = [vy_switch{patch_idx(2)} [y; 0; 0; y; y]];
            y = nanmean(y_speed_23C);
            vy_speed{patch_idx(1)} = [vy_speed{patch_idx(1)} [y; 0; 0; y; y]];
            y = nanmean(y_speed_33C);
            vy_speed{patch_idx(2)} = [vy_speed{patch_idx(2)} [y; 0; 0; y; y]];
            y = nanmean(y_bout_23C);
            vy_bout{patch_idx(1)} = [vy_bout{patch_idx(1)} [y; 0; 0; y; y]];
            y = nanmean(y_bout_33C);
            vy_bout{patch_idx(2)} = [vy_bout{patch_idx(2)} [y; 0; 0; y; y]];
            
            % record rvalues
            ldm_screen.rvals{ct} = corr([y_clump_23C' y_clump_33C' y_switch_23C'...
                y_switch_33C' y_bout_23C' y_bout_33C' y_speed_23C' y_speed_33C'],...
                'Type','Spearman');
            
            y = corr([y_clump_23C' y_bout_23C'],'Type','Spearman','rows','pairwise');
            y = y(1,2);
            vy_rval{patch_idx(1)} = [vy_rval{patch_idx(1)} [y; 0; 0; y; y]];
            y = corr([y_clump_33C' y_bout_33C'],'Type','Spearman','rows','pairwise');
            y = y(1,2);
            vy_rval{patch_idx(2)} = [vy_rval{patch_idx(2)} [y; 0; 0; y; y]];            
        end
    end
end

% plot clumpiness
figure;
subplot(5,1,1);
hold on;
ph = gobjects(6,1);
ph(1) = patch('XData',vx{1},'YData',vy_clump{1},'FaceColor',[1 0.8 .3],...
    'EdgeColor','none','LineWidth',0.25);
ph(2) = patch('XData',vx{2},'YData',vy_clump{2},'FaceColor',[1 0.5 0],...
    'EdgeColor','none','LineWidth',0.25);
ph(3) = patch('XData',vx{3},'YData',vy_clump{3},'FaceColor',[.7 .7 .7],...
    'EdgeColor','none','LineWidth',0.25);
ph(4) = patch('XData',vx{4},'YData',vy_clump{4},'FaceColor',[.4 .4 .4],...
    'EdgeColor','none','LineWidth',0.25);
ph(5) = patch('XData',vx{5},'YData',vy_clump{5},'FaceColor',[.5 .5 1],...
    'EdgeColor','none','LineWidth',0.25);
ph(6) = patch('XData',vx{6},'YData',vy_clump{6},'FaceColor',[.2 .2 1],...
    'EdgeColor','none','LineWidth',0.25);

% plot confidence intervals
plot(ci_x(:),ci_clump(:),'k','LineWidth',0.25);

x_offset = bar_width*numel(vx)/2+bar_width/2;
label_x = x_offset:1:(numel(unique_bgs)+x_offset);
set(gca,'XLim',[0 max(vx{6}(:))],'YLim',get(gca,'YLim').*1,...
    'XTick',label_x,'XTickLabel',unique_bgs,...
    'XTickLabelRotation',90,'TickLength',[0 0]);
ylabel('clumpiness');
leg_labels = {'Shi 23C';'Shi 33C';'Iso 23C';'Iso 33C';'Trp 23C';'Trp 33C'};
legend(ph,leg_labels);

% plot switchiness
subplot(5,1,2);
hold on;
ph = gobjects(6,1);
ph(1) = patch('XData',vx{1},'YData',vy_switch{1},'FaceColor',[1 0.8 .3],...
    'EdgeColor','none','LineWidth',0.25);
ph(2) = patch('XData',vx{2},'YData',vy_switch{2},'FaceColor',[1 0.5 0],...
    'EdgeColor','none','LineWidth',0.25);
ph(3) = patch('XData',vx{3},'YData',vy_switch{3},'FaceColor',[.7 .7 .7],...
    'EdgeColor','none','LineWidth',0.25);
ph(4) = patch('XData',vx{4},'YData',vy_switch{4},'FaceColor',[.4 .4 .4],...
    'EdgeColor','none','LineWidth',0.25);
ph(5) = patch('XData',vx{5},'YData',vy_switch{5},'FaceColor',[.5 .5 1],...
    'EdgeColor','none','LineWidth',0.25);
ph(6) = patch('XData',vx{6},'YData',vy_switch{6},'FaceColor',[.2 .2 1],...
    'EdgeColor','none','LineWidth',0.25);

% plot confidence intervals
plot(ci_x(:),ci_switch(:),'k','LineWidth',0.25);

x_offset = bar_width*numel(vx)/2+bar_width/2;
label_x = x_offset:1:(numel(unique_bgs)+x_offset);
set(gca,'XLim',[0 max(vx{6}(:))],'YLim',get(gca,'YLim').*1.5,...
    'XTick',label_x,'XTickLabel',unique_bgs,...
    'XTickLabelRotation',90,'TickLength',[0 0]);
ylabel('switchiness');

% plot switchiness
subplot(5,1,3);
hold on;
ph = gobjects(6,1);
ph(1) = patch('XData',vx{1},'YData',vy_rval{1},'FaceColor',[1 0.8 .3],...
    'EdgeColor','none','LineWidth',0.25);
ph(2) = patch('XData',vx{2},'YData',vy_rval{2},'FaceColor',[1 0.5 0],...
    'EdgeColor','none','LineWidth',0.25);
ph(3) = patch('XData',vx{3},'YData',vy_rval{3},'FaceColor',[.7 .7 .7],...
    'EdgeColor','none','LineWidth',0.25);
ph(4) = patch('XData',vx{4},'YData',vy_rval{4},'FaceColor',[.4 .4 .4],...
    'EdgeColor','none','LineWidth',0.25);
ph(5) = patch('XData',vx{5},'YData',vy_rval{5},'FaceColor',[.5 .5 1],...
    'EdgeColor','none','LineWidth',0.25);
ph(6) = patch('XData',vx{6},'YData',vy_rval{6},'FaceColor',[.2 .2 1],...
    'EdgeColor','none','LineWidth',0.25);

x_offset = bar_width*numel(vx)/2+bar_width/2;
label_x = x_offset:1:(numel(unique_bgs)+x_offset);
set(gca,'XLim',[0 max(vx{6}(:))],...
    'XTick',label_x,'XTickLabel',unique_bgs,...
    'XTickLabelRotation',90,'TickLength',[0 0]);
ylabel('r-value (clump vs. switch)');

% plot speed
subplot(5,1,4);
hold on;
ph = gobjects(6,1);
ph(1) = patch('XData',vx{1},'YData',vy_speed{1},'FaceColor',[1 0.8 .3],...
    'EdgeColor','none','LineWidth',0.25);
ph(2) = patch('XData',vx{2},'YData',vy_speed{2},'FaceColor',[1 0.5 0],...
    'EdgeColor','none','LineWidth',0.25);
ph(3) = patch('XData',vx{3},'YData',vy_speed{3},'FaceColor',[.7 .7 .7],...
    'EdgeColor','none','LineWidth',0.25);
ph(4) = patch('XData',vx{4},'YData',vy_speed{4},'FaceColor',[.4 .4 .4],...
    'EdgeColor','none','LineWidth',0.25);
ph(5) = patch('XData',vx{5},'YData',vy_speed{5},'FaceColor',[.5 .5 1],...
    'EdgeColor','none','LineWidth',0.25);
ph(6) = patch('XData',vx{6},'YData',vy_speed{6},'FaceColor',[.2 .2 1],...
    'EdgeColor','none','LineWidth',0.25);

% plot confidence intervals
plot(ci_x(:),ci_speed(:),'k','LineWidth',0.25);

x_offset = bar_width*numel(vx)/2+bar_width/2;
label_x = x_offset:1:(numel(unique_bgs)+x_offset);
set(gca,'XLim',[0 max(vx{6}(:))],'YLim',get(gca,'YLim').*1.5,...
    'XTick',label_x,'XTickLabel',unique_bgs,...
    'XTickLabelRotation',90,'TickLength',[0 0]);
ylabel('speed');

% plot bouts
subplot(5,1,5);
hold on;
ph = gobjects(6,1);
ph(1) = patch('XData',vx{1},'YData',vy_bout{1},'FaceColor',[1 0.8 .3],...
    'EdgeColor','none','LineWidth',0.25);
ph(2) = patch('XData',vx{2},'YData',vy_bout{2},'FaceColor',[1 0.5 0],...
    'EdgeColor','none','LineWidth',0.25);
ph(3) = patch('XData',vx{3},'YData',vy_bout{3},'FaceColor',[.7 .7 .7],...
    'EdgeColor','none','LineWidth',0.25);
ph(4) = patch('XData',vx{4},'YData',vy_bout{4},'FaceColor',[.4 .4 .4],...
    'EdgeColor','none','LineWidth',0.25);
ph(5) = patch('XData',vx{5},'YData',vy_bout{5},'FaceColor',[.5 .5 1],...
    'EdgeColor','none','LineWidth',0.25);
ph(6) = patch('XData',vx{6},'YData',vy_bout{6},'FaceColor',[.2 .2 1],...
    'EdgeColor','none','LineWidth',0.25);

% plot confidence intervals
plot(ci_x(:),ci_bout(:),'k','LineWidth',0.25);

x_offset = bar_width*numel(vx)/2+bar_width/2;
label_x = x_offset:1:(numel(unique_bgs)+x_offset);
set(gca,'XLim',[0 max(vx{6}(:))],'YLim',get(gca,'YLim').*1.5,...
    'XTick',label_x,'XTickLabel',unique_bgs,...
    'XTickLabelRotation',90,'TickLength',[0 0]);
ylabel('bout clumpiness');

%% scatter per line mean clumpiness per condition

nplots = 4;
ax = gobjects(nplots,1);
ax(1) = subplot(1,nplots,1);
ax(2) = subplot(1,nplots,2);
colors = {[1 0.5 0];[.4 .4 .4];[.2 .2 1]};

x_23 =zscore(cellfun(@nanmean,ldm_screen.clumpiness.mean_23C));
y_23 =zscore(cellfun(@nanmean,ldm_screen.switchiness.mean_23C));
x_33 =zscore(cellfun(@nanmean,ldm_screen.clumpiness.mean_33C));
y_33 =zscore(cellfun(@nanmean,ldm_screen.switchiness.mean_33C));

% calculate projection of points onto the vector x=1, y=1
d_pts = NaN(numel(x_23),2);
d_pts(:,1) = ([x_23 y_23]*[1;1])./([1 1]*[1;1]);
d_pts(:,2) = ([x_33 y_33]*[1;1])./([1 1]*[1;1]);
d_eff = NaN(numel(unique_effs),2);
r_eff = NaN(numel(unique_effs),2);
ci_d = NaN(3,6);
ci_r = NaN(3,6);
for i=1:numel(unique_effs)
    % group data by effector type
    eff_idx = strcmpi(ldm_screen.effector,unique_effs{i});
    
    % plot data at low temp
    hold(ax(1),'on');
    pretty_scatter(x_23(eff_idx),y_23(eff_idx),colors{i},'MarkerSize',3,'Parent',ax(1));
    xlabel(ax(1),'Clumpiness');
    ylabel(ax(1),'Switchiness');
    r = corr([x_23 y_23],'Type','Spearman');
    title(ax(1),sprintf('Temp = 23C; r = %0.2f',r(1,2)));
    dd = abs(d_pts(eff_idx,1));
    d_eff(i,1) = mean(dd);
    ci_d(1:2,i) = bootstrap_mean_CI(dd,0.05,1000);
    
    bs_r = bootstrap_rvalues([x_23(eff_idx) y_23(eff_idx)],1000);
    r_eff(i,1) = mean(bs_r(1,2,:));
    ci_r(1:2,i) = bootstrap_mean_CI(squeeze(bs_r(1,2,:)),0.05,1000);
    
    % plot data at high temp
    hold(ax(2),'on');
    pretty_scatter(x_33(eff_idx),y_33(eff_idx),colors{i},'MarkerSize',3,'Parent',ax(2));
    xlabel(ax(2),'Clumpiness');
    ylabel(ax(2),'Switchiness');
    r = corr([x_33 y_33],'Type','Spearman');
    title(ax(2),sprintf('Temp = 33C; r = %0.2f',r(1,2)));
    dd = abs(d_pts(eff_idx,2));
    d_eff(i,2) = mean(dd);
    ci_d(1:2,i+3) = bootstrap_mean_CI(dd,0.05,1000);
    
    bs_r = bootstrap_rvalues([x_33(eff_idx) y_33(eff_idx)],1000);
    r_eff(i,2) = mean(bs_r(1,2,:));
    ci_r(1:2,i+3) = bootstrap_mean_CI(squeeze(bs_r(1,2,:)),0.05,1000);
end

plot([-3 3],[-3 3],'k--','Parent',ax(1));
plot([-3 3],[-3 3],'k--','Parent',ax(2));
for i=1:2
   set(ax(i),'XLim',[-3 3],'YLim',[-3 3]); 
end

% plot projection values
ax(3) = subplot(1,4,3);
bh = bar(d_eff');
ngroups = size(d_eff, 2);
nbars = size(d_eff, 1);
groupwidth = min(0.8, nbars/(nbars + 1.5));
x = NaN(3,2);
for i=1:numel(bh)
    bh(i).FaceColor = colors{i};
    x(i,1:2) = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
end
x = [x(:)'; x(:)'; NaN(1,numel(x))];
hold on;
plot(x(:), ci_d(:), 'k-','LineWidth',1);
set(ax(3),'YLim',[0 1.5],'XTickLabel',{'23C';'33C'});
ylabel('|proj(x=y)|');
legend(bh,{'Shi';'Iso';'Trp'});

% plot r-values
ax(4) = subplot(1,4,4);
bh = bar(r_eff');
ngroups = size(r_eff, 2);
nbars = size(r_eff, 1);
groupwidth = min(0.8, nbars/(nbars + 1.5));
x = NaN(3,2);
for i=1:numel(bh)
    bh(i).FaceColor = colors{i};
    x(i,1:2) = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
end
x = [x(:)'; x(:)'; NaN(1,numel(x))];
hold on;
plot(x(:), ci_r(:), 'k-','LineWidth',1);
set(ax(4),'YLim',[0 1],'XTickLabel',{'23C';'33C'});
ylabel('correlation');
legend(bh,{'Shi';'Iso';'Trp'});

%%
figure;
ax(1) = subplot(3,2,1);
x = cellfun(@nanmean,ldm_screen.clumpiness.mean_23C);
y = cellfun(@nanmean,ldm_screen.switchiness.mean_23C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Clumpiness');
ylabel('Switchiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (23C), r=%0.2f',r(1,2)));

ax(2) = subplot(3,2,2);
x = cellfun(@nanmean,ldm_screen.clumpiness.mean_33C);
y = cellfun(@nanmean,ldm_screen.switchiness.mean_33C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Clumpiness');
ylabel('Switchiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (33C), r=%0.2f',r(1,2)));

ax(1) = subplot(3,2,3);
y = cellfun(@nanmean,ldm_screen.clumpiness.mean_23C);
x = cellfun(@nanmean,ldm_screen.speed.mean_23C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (23C), r=%0.2f',r(1,2)));

ax(2) = subplot(3,2,4);
y = cellfun(@nanmean,ldm_screen.clumpiness.mean_33C);
x = cellfun(@nanmean,ldm_screen.speed.mean_33C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (33C), r=%0.2f',r(1,2)));

ax(1) = subplot(3,2,5);
y = cellfun(@nanmean,ldm_screen.switchiness.mean_23C);
x = cellfun(@nanmean,ldm_screen.speed.mean_23C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Switchiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (23C), r=%0.2f',r(1,2)));

ax(2) = subplot(3,2,6);
y = cellfun(@nanmean,ldm_screen.switchiness.mean_33C);
x = cellfun(@nanmean,ldm_screen.speed.mean_33C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Switchiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (33C), r=%0.2f',r(1,2)));

%% scatter plots clumpiness vs. bout clumpiness vs. speed

figure;
ax(1) = subplot(3,2,1);
x = cellfun(@nanmean,ldm_screen.clumpiness.mean_23C);
y = cellfun(@nanmean,ldm_screen.bout.mean_23C)';
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Clumpiness');
ylabel('Bout Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (23C), r=%0.2f',r(1,2)));

ax(2) = subplot(3,2,2);
x = cellfun(@nanmean,ldm_screen.clumpiness.mean_33C);
y = cellfun(@nanmean,ldm_screen.bout.mean_33C)';
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Clumpiness');
ylabel('Bout Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (33C), r=%0.2f',r(1,2)));

ax(1) = subplot(3,2,3);
y = cellfun(@nanmean,ldm_screen.bout.mean_23C)';
x = cellfun(@nanmean,ldm_screen.speed.mean_23C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Bout Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (23C), r=%0.2f',r(1,2)));

ax(2) = subplot(3,2,4);
y = cellfun(@nanmean,ldm_screen.bout.mean_33C)';
x = cellfun(@nanmean,ldm_screen.speed.mean_33C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Bout Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (33C), r=%0.2f',r(1,2)));

ax(1) = subplot(3,2,5);
y = cellfun(@nanmean,ldm_screen.clumpiness.mean_23C);
x = cellfun(@nanmean,ldm_screen.speed.mean_23C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (23C), r=%0.2f',r(1,2)));

ax(2) = subplot(3,2,6);
y = cellfun(@nanmean,ldm_screen.clumpiness.mean_33C);
x = cellfun(@nanmean,ldm_screen.speed.mean_33C);
PCARegressionCI(nanzscore([x y]),[isnan(x) isnan(y)],gca);
xlabel('Speed');
ylabel('Clumpiness');
r = corr([x y],'Type','Pearson','rows','pairwise');
title(sprintf('line averages (33C), r=%0.2f',r(1,2)));

%%

% plot switch/clump rval vs speed
ax(3) = subplot(1,3,3);
y = cat(2,vy_rval{:});
y = y(1,:)';
x = cat(2,vy_speed{:});
x = x(1,:)';
missing = isnan(y) | isnan(x);
PCARegressionCI([x(~missing) y(~missing)],...
    [isnan(x(~missing)) isnan(y(~missing))],gca,'XLim',[0 16],'YLim',[-1 1]);
xlabel('Speed');
ylabel('r-val (switch vs. clump)');
r = corr([x y],'Type','Spearman','rows','pairwise');
title(sprintf('all lines and conditions, r=%0.2f',r(1,2)));

%%

rvals = cat(3,vy_rval{:});
rvals = squeeze(rvals(1,:,[1 3 5 2 4 6]));
rvals = num2cell(rvals,1);

figure;
plot([0 7],[0 0],'k--','LineWidth',0.5);
hold on;
violinPlot(rvals,'Labels',leg_labels([1 3 5 2 4 6])');
ylabel('r-value (clump v. switch)');
set(gca,'TickLength',[0 0],'YLim',[-1 1]);
title('within line r-value distributions');

%% plot bar plots for specific lines

bw = 0.1;
leg_labels = {'Shi 23C';'Shi 33C';'Iso 23C';'Iso 33C';'Trp 23C';'Trp 33C'};
metric_labels = {'Bout Clumpiness';'Speed';'Clumpiness';'Switchiness';'r-value'};

line = 'SS02255';
line_idx = find(strcmp(unique_bgs,line));
vv = cat(2,vy_bout,vy_speed,vy_clump,vy_switch,vy_rval);
vy_grps = cell(numel(leg_labels),1);

for i=1:numel(vy_grps)
    y = cellfun(@(v) v(:,line_idx),vv(i,:),'UniformOutput',false);
    vy_grps{i} =  cat(2,y{:});
end

missing_grps = squeeze(any(any(isnan(cat(3,vy_grps{:})),1)));
vy_grps(missing_grps) = [];
ngrps = sum(~missing_grps);
spc = bw*(ngrps+1);
xx = linspace(0,bw*(ngrps-1),ngrps);
vx_grps = [xx; xx; xx+bw; xx+bw; xx];


figure;
ah = gobjects(ngrps,1);
for i = 1:size(vv,2)
    ah(i) = subplot(1,size(vv,2),i);
    hold(ah(i),'on');
end

colors = {[1 0.8 .3];[1 0.5 0];[.7 .7 .7];[.4 .4 .4];[.5 .5 1];[.2 .2 1]};
colors(missing_grps) = [];

for j=1:size(vv,2)
    ph = gobjects(ngrps,1);
    ymin= 0;
    ymax= 0;
    for i=1:ngrps
        ph(i) = patch('XData',vx_grps(:,i),'YData',vy_grps{i}(:,j),...
            'FaceColor',colors{i},'EdgeColor','none','LineWidth',0.25,'Parent',ah(j));
        ymin(ymin>min(vy_grps{i}(:,j))) = min(vy_grps{i}(:,j));
        ymax(ymax<max(vy_grps{i}(:,j))) = max(vy_grps{i}(:,j));
    end
    set(ah(j),'XLim',[-bw (ngrps+1)*bw],'Ylim',[ymin ymax].*1.5,'XTick',[]);
    ylabel(ah(j),metric_labels{j});
    xlabel(ah(j),line);
    legend(ph,leg_labels(~missing_grps));
end

%% plot correlation matrices

nrows = ceil(sqrt(numel(ldm_screen.gal4)));
ncol = ceil(numel(ldm_screen.gal4)/nrows);
figure;
cmap = interp1([1 52 128 129 164 225 256],[0 1 1; 0 .2 1;...
        0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
for i=1:numel(ldm_screen.gal4)
    ah = subplot(nrows,ncol,i);
    r=ldm_screen.rvals{i};
    r(isnan(r)) = 0;
    if all(~isempty(r))
        imagesc(r,'Parent',ah);
    else
        imagesc(zeros(8,8),'Parent',ah);
    end
    set(ah,'XTick',[],'YTick',[]);
    xlabel(ah,sprintf('%s %s',ldm_screen.gal4{i},ldm_screen.effector{i}));
    caxis(ah,[-1 1]);
    colormap(ah,cmap);  
end


