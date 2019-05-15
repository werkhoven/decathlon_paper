function turns = parse_v2_ymaze_data(flyTracks)

% get turn indices
turns.idx = ~isnan(flyTracks.rightTurns);
turns.idx = num2cell(turns.idx,1);
turns.idx = cellfun(@find,turns.idx,'UniformOutput',false);

% convert sequence of maze arms to left/right turn sequence
arm_sequence = cellfun(@(aseq,ti) aseq(ti), ...
    num2cell(flyTracks.rightTurns,1), turns.idx, 'UniformOutput', false);
turn_sequence = cellfun(@score_turns,arm_sequence,num2cell(flyTracks.mazeOri)',...
    'UniformOutput', false);

% remove first turn
no_turns = cellfun(@numel,turns.idx)<1;
trim_turns = cellfun(@(ti) ti(2:end), turns.idx(~no_turns), 'UniformOutput', false);
turns.idx(no_turns) = {[]};
turns.idx(~no_turns) = trim_turns;
turns.n = cellfun(@numel,turns.idx);
clear trim_turns no_turns

% Calculate turn metrics
turns.t = cellfun(@(ti) flyTracks.tStamps(ti), turns.idx, 'UniformOutput', false);
turns.right_bias = cellfun(@sum,turn_sequence)./turns.n;
turns.switchiness = cellfun(@(s,r,nt) sum((s(1:end-1)+s(2:end))==1)/(2*r*(1-r)*nt),...
    turn_sequence,num2cell(turns.right_bias),num2cell(turns.n));
turns.clumpiness = cellfun(@(t,nt) std(diff([0;t]))/(flyTracks.tStamps(end)/nt),...
    turns.t, num2cell(turns.n));


function turn_seq = score_turns(arm_seq,ori)

tSeq=diff(arm_seq);  
if ori
    turn_seq = tSeq==1 | tSeq==-2;
else
    turn_seq = tSeq==-1 | tSeq==2;
end
