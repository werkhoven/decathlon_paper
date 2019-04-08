function [data,fn] = getDataFields_legacy(expmt)

    switch expmt.Name
        
        case 'Arena'
            
            data.circling = expmt.handedness.mu;
            data.speed = nanmean(expmt.Speed.data);
            data.filter = data.speed > 0.005;

        case 'Y-maze'     
            
            idx = 1:size(expmt.labels_table,1);
            expmt.nTracks = length(idx);
            
            data.circling = expmt.handedness.mu(idx);
            data.right_bias = expmt.Turns.rBias(idx);
            data.nTrials = expmt.Turns.n(idx);
            data.hand_clumpiness = expmt.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.Turns.switchiness(idx);
            data.speed = nanmean(expmt.Speed.data(:,idx));
            data.filter = expmt.Turns.active(idx);

        case 'LED Y-maze'

            idx = expmt.labels{1,4}:expmt.labels{1,5};
            expmt.nTracks = length(idx);

            data.circling = expmt.handedness.mu(idx);
            data.right_bias = expmt.Turns.rBias(idx);
            data.light_bias = expmt.LightChoice.pBias(idx);
            data.nTrials = expmt.Turns.n(idx);
            data.hand_clumpiness = expmt.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.Turns.switchiness(idx);
            data.light_switchiness = expmt.LightChoice.switchiness(idx);
            data.speed = nanmean(expmt.Speed.data(:,idx));
            data.filter = expmt.Turns.active(idx);

        case 'Slow Phototaxis'

            data.circling = expmt.handedness.mu;
            data.circling_blank = expmt.handedness_Blank.mu;
            data.nTrials = sum(cell2mat(expmt.Light.tInc)>0.005);
            data.occupancy = expmt.Light.avg_occ;
            data.speed = nanmean(expmt.Speed.data);
            data.filter = data.speed > 0.005;

        case 'Optomotor'

            data.circling = expmt.handedness.mu;
            data.optomotor_index = -expmt.Optomotor.index;
            data.speed =  nanmean(expmt.Speed.data);
            data.nTrials = expmt.Optomotor.n;
            data.filter = data.speed > 0.005;

        case 'Circadian'

            data.circling = expmt.handedness.mu;
            data.speed =  nanmean(expmt.Speed.data);
            data.filter = data.speed > 0.005;
            if isfield(expmt,'Gravity')
                data.gravitactic_index = expmt.Gravity.index;
            end
            
        case 'Temporal Phototaxis'
            
            data.circling = expmt.handedness.mu;
            data.occupancy = expmt.LightStatus.occ;
            data.nTrials = expmt.Lightstatus.n;
            data.iti = expmt.LightStatus.iti;
            data.speed = nanmean(expmt.Speed.data);
            data.filter = data.speed > 0.005;
            
        case 'Olfaction'
            
            data.occupancy = expmt.occupancy;
            data.preodor_occupancy = expmt.preOdorOccupancy;
            data.right_bias = expmt.Turns.rBias;
            data.hand_clumpiness = expmt.Turns.clumpiness;
            data.hand_switchiness = expmt.Turns.switchiness;
            data.speed = nanmean(expmt.velocity);
            data.filter = data.speed > 1;

        otherwise
            errordlg('Experiment name not recognized, no analysis performed');
            
    end
    
    % standardize dimensions
    fn = fieldnames(data);
    for i = 1:length(fn)
        tmp = data.(fn{i});
        if find(size(tmp)==expmt.nTracks,1)==2
            data.(fn{i}) = data.(fn{i})';
        end
    end
    
    fn(strmatch('filter',fn))=[];
        
    
end