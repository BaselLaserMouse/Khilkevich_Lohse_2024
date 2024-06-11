%% Extract_TFs_For_FullGLM

%% Separate TFs into ealy and two parts of late blocks
if BehavData.Raw.TempBlock(curTrial)==0 % early
    %% if the duration is shorter than the base line extract only baseline values during the actual tria
    if trial(curTrial).duration<(BehavData.Raw.BaseT(SelectTrial)*1000)
        trial(curTrial).instantTFEarlyBlock1 = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
        trial(curTrial).instantTFLateBlock1 = zeros(trial(curTrial).duration/binSize,1);
        trial(curTrial).instantTFLateBlock2 = zeros(trial(curTrial).duration/binSize,1);
        
    else
        trial(curTrial).instantTFEarlyBlock1 = BaseTFFrames_to_ms(BehavData.Raw.TF,BehavData.Raw.BaseT*1000,binSize,SelectTrial);
        trial(curTrial).instantTFLateBlock1 = zeros(trial(curTrial).duration/binSize,1);
        trial(curTrial).instantTFLateBlock2 = zeros(trial(curTrial).duration/binSize,1);
        
    end
elseif BehavData.Raw.TempBlock(curTrial)==1 % late
    clear BaseMidPoint
    BaseMidPoint=floor(((BehavData.Raw.BaseT(SelectTrial)*1000)/binSize)/2); % split late block in the middle
    
    if trial(curTrial).duration<(BehavData.Raw.BaseT(SelectTrial)*1000)
        if trial(curTrial).duration<(BaseMidPoint*binSize)
            trial(curTrial).instantTFLateBlock1 = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
            
            trial(curTrial).instantTFLateBlock1(1:trial(curTrial).duration/binSize) = 0;
            trial(curTrial).instantTFLateBlock2 = zeros(trial(curTrial).duration/binSize,1);
        else
            trial(curTrial).instantTFLateBlock1 = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
            trial(curTrial).instantTF_LateBlock1(1:BaseMidPoint) = 0;
            
            trial(curTrial).instantTFLateBlock2 = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
            trial(curTrial).instantTFLateBlock2(BaseMidPoint:end) = 0;
        end
        trial(curTrial).instantTFEarlyBlock1 = zeros(trial(curTrial).duration/binSize,1);
    else
        trial(curTrial).instantTFLateBlock1 = BaseTFFrames_to_ms(BehavData.Raw.TF,BehavData.Raw.BaseT*1000,binSize,SelectTrial);
        trial(curTrial).instantTFLateBlock2 = BaseTFFrames_to_ms(BehavData.Raw.TF,BehavData.Raw.BaseT*1000,binSize,SelectTrial);
        
        trial(curTrial).instantTFLateBlock1(1:BaseMidPoint) = 0;
        trial(curTrial).instantTFLateBlock2(BaseMidPoint:end) = 0;
        
        trial(curTrial).instantTFEarlyBlock1 = zeros(trial(curTrial).duration/binSize,1);
    end
end

%% Separate TFs into early and late blocks
if BehavData.Raw.TempBlock(curTrial)==0 % early
    %% if the duration is shorter than the base line extract only baseline values during the actual tria
    if trial(curTrial).duration<(BehavData.Raw.BaseT(SelectTrial)*1000)
        trial(curTrial).instantTF_EarlyBlock = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
        trial(curTrial).instantTF_LateBlock = zeros(trial(curTrial).duration/binSize,1);
    else
        trial(curTrial).instantTF_EarlyBlock = BaseTFFrames_to_ms(BehavData.Raw.TF,BehavData.Raw.BaseT*1000,binSize,SelectTrial);
        trial(curTrial).instantTF_LateBlock = zeros(trial(curTrial).duration/binSize,1);
    end
elseif BehavData.Raw.TempBlock(curTrial)==1 % late
    if trial(curTrial).duration<(BehavData.Raw.BaseT(SelectTrial)*1000)
        trial(curTrial).instantTF_LateBlock = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
        trial(curTrial).instantTF_EarlyBlock = zeros(trial(curTrial).duration/binSize,1);
    else
        trial(curTrial).instantTF_LateBlock = BaseTFFrames_to_ms(BehavData.Raw.TF,BehavData.Raw.BaseT*1000,binSize,SelectTrial);
        trial(curTrial).instantTF_EarlyBlock = zeros(trial(curTrial).duration/binSize,1);
    end
end

%% Also extract all baseline TFs and phase
if trial(curTrial).duration<(BehavData.Raw.BaseT(SelectTrial)*1000)
    %extract TF
    [trial(curTrial).instantTF, trial(curTrial).instantTFSlow,trial(curTrial).instantTFFast] = BaseTFFrames_to_ms(BehavData.Raw.TF,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial);
    % Extract phase
    %trial(curTrial).Phase= BasePhaseFrames_to_ms(BehavData.Raw.phase,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial,1);

    if BehavData.Raw.Ori{(SelectTrial)}==90
        trial(curTrial).PhaseUP= BasePhaseFrames_to_ms(BehavData.Raw.phase,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial,2);
        trial(curTrial).PhaseDOWN= zeros(length(trial(curTrial).PhaseUP),1);
    elseif BehavData.Raw.Ori{(SelectTrial)}==270
        trial(curTrial).PhaseDOWN= BasePhaseFrames_to_ms(BehavData.Raw.phase,ones(nTrials,1)*trial(curTrial).duration,binSize,SelectTrial,2);
        trial(curTrial).PhaseUP= zeros(length(trial(curTrial).PhaseDOWN),1);
    end
else
    %extract TF
    [trial(curTrial).instantTF, trial(curTrial).instantTFSlow,trial(curTrial).instantTFFast] = BaseTFFrames_to_ms(BehavData.Raw.TF,BehavData.Raw.BaseT*1000,binSize,SelectTrial);
            
    % Extract phase
       % trial(curTrial).Phase= BasePhaseFrames_to_ms(BehavData.Raw.phase,BehavData.Raw.BaseT*1000,binSize,SelectTrial,1);

    if BehavData.Raw.Ori{(SelectTrial)}==90
        trial(curTrial).PhaseUP= BasePhaseFrames_to_ms(BehavData.Raw.phase,BehavData.Raw.BaseT*1000,binSize,SelectTrial,2);
        trial(curTrial).PhaseDOWN= zeros(length(trial(curTrial).PhaseUP),1);
        
    elseif BehavData.Raw.Ori{(SelectTrial)}==270
        trial(curTrial).PhaseDOWN= BasePhaseFrames_to_ms(BehavData.Raw.phase,BehavData.Raw.BaseT*1000,binSize,SelectTrial,2);
        trial(curTrial).PhaseUP= zeros(length(trial(curTrial).PhaseDOWN),1);
    end
end

