function [instantPhases] = PhaseFrames_to_ms(Phase,BaseT,binSize,SelectTrial,PhaseSelect)

% resmaple stim from frames into ms
Frames=length(Phase{SelectTrial}(find(Phase{SelectTrial}(:,1)~=0),1));
FramePhases=Phase{SelectTrial}(find(Phase{SelectTrial}(:,1)~=0),1);
PulsePhasesMat=reshape(FramePhases,3,Frames/3);
msPhasesMat=(repmat(PulsePhasesMat(1,:),50,1));
clear instantPhases
instantPhasestemp=msPhasesMat(:);

if PhaseSelect ==1 % extract phase form fsm info
    
    % instantPhasestemp(floor(BaseT(SelectTrial)):end)=1;
   % instantPhasesWrap=(wrapTo360(instantPhasestemp));
    ZinstantPhases=zscore(sin(deg2rad(wrapTo360(instantPhasestemp))));
    % Each trial is zscored independently, so get the trial mean closer to zero, by taking the period outside of abseline
    % and rezeroing it, to crate uniformity across trials.
    ZinstantPhases(floor(BaseT(SelectTrial)):end)=0; % zero values outside of baseline
    ZinstantPhases=zscore(ZinstantPhases);
    ZinstantPhases(floor(BaseT(SelectTrial)):end)=0;
    
    % now resample to bin size
    clear instantPhases
    instantPhases=ZinstantPhases(1:binSize:end);
    
elseif PhaseSelect ==0  % 1 hz sinewave
    
    %  ZinstantPhases=(wrapTo360(instantPhasestemp));
    
    fs = 1000;                    % Sampling frequency (samples per second)
    dt = 1/fs;                   % seconds per sample
    StopTime = length(instantPhasestemp)/1000;             % seconds
    t = (0:dt:StopTime-dt)';     % seconds
    F = 1;                      % Sine wave frequency (hertz)
    ZinstantPhases = sin(2*pi*F*t).*1.4142; % this is equvalanent to zscoring
    ZinstantPhases(floor(BaseT(SelectTrial)):end)=0;
    
    % now resample to bin size
    clear instantPhases
    instantPhases=ZinstantPhases(1:binSize:end);
    
elseif PhaseSelect ==2  % actual phase values

         % instantPhasestemp(floor(BaseT(SelectTrial)):end)=1;
   % instantPhasesWrap=(wrapTo360(instantPhasestemp));
    %ZinstantPhases=zscore(sin(deg2rad(wrapTo360(instantPhasestemp))));
    TempinstantPhases=(((wrapTo360(instantPhasestemp))));

    TempinstantPhases(floor(BaseT(SelectTrial)):end)=0; % zero values outside of baseline
    %ZinstantPhases=zscore(ZinstantPhases);
    %ZinstantPhases(floor(BaseT(SelectTrial)):end)=0;
    
    % now resample to bin size
    clear instantPhases
    instantPhases=TempinstantPhases(1:binSize:end);
    
end




