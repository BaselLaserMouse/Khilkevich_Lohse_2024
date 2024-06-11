function [instantTFs,instantTFsSlow,instantTFsFast] = BaseTFFrames_to_ms(TF,BaseT,binSize,SelectTrial)

    % resample stim from frames into ms
    Frames=length(TF{SelectTrial}(find(TF{SelectTrial}~=0 & ~isnan(TF{SelectTrial}))));
    FrameTFs=TF{SelectTrial}(find(TF{SelectTrial}~=0 & ~isnan(TF{SelectTrial})));
    PulseTFsMat=reshape(FrameTFs,3,Frames/3);
    msTFsMat=(repmat(PulseTFsMat(1,:),50,1));
    clear instantTFs
    instantTFstemp=log2(msTFsMat(:)); % octave
    instantTFstemp(floor(BaseT(SelectTrial)):end)=0;
    ZinstantTFs=(instantTFstemp)./0.25; % noise has a std of 0.25.  This zscores it.
    ZinstantTFs(floor(BaseT(SelectTrial)):end)=0;

    % now resample to bin size and include separate variale for fast and
    % slow TFs
    clear instantTFs
    instantTFs=ZinstantTFs(1:binSize:end);
    
    instantTFsSlow=instantTFs;
    instantTFsSlow(instantTFsSlow>0)=0; % should these also be normalised?
    
    instantTFsFast=instantTFs;
    instantTFsFast(instantTFsFast<0)=0;  % should these also be normalised?