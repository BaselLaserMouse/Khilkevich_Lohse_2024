
%%  Plot

for curClu=1:length(Expt(e).GLMparams.CluSelect) % which cluster to plot
    %colormap=redblue
    
    figure(curClu)
    clf
    Temp=['Filters for unit ' num2str(Expt(e).GLMparams.CluSelect(curClu))];
    set(gcf,'Name',Temp,'NumberTitle','off')
    clear Temp
    subplot(2,2,1);  % ML filter
    if Expt(e).GLMparams.nkx>1
        imagesc(Expt(e).Clu(curClu).GLM.ML.k);
    else
        plot([1:Expt(e).GLMparams.nkt].*Expt(e).GLMparams.dtStim,Expt(e).Clu(CluSelect(curClu)).GLM.ML.k,'linewidth',1.75);xlabel('time');
        box off
    end
    title('ML estimate'); ylabel('time');
    
    subplot(2,2,2); % Filter with L2
    if nkx>1
        imagesc(Expt(e).Clu(CluSelect(curClu)).GLM.L2.k); title('MAP: ridge prior'); xlabel('space'); ylabel('time');
    else
        plot([1:Expt(e).GLMparams.nkt].*Expt(e).GLMparams.dtStim,Expt(e).Clu(CluSelect(curClu)).GLM.L2.k,'linewidth',1.75); title('MAP: ridge prior'); xlabel('time')
        box off
    end
    
    subplot(2,2,3); % Filter with smoothing prior
    if nkx>1
        imagesc(Expt(e).Clu(CluSelect(curClu)).GLM.Smooth.k); title('MAP: smoothing prior'); xlabel('space');ylabel('time');
    else
        plot([1:Expt(e).GLMparams.nkt].*Expt(e).GLMparams.dtStim,Expt(e).Clu(CluSelect(curClu)).GLM.Smooth.k,'linewidth',1.75); title('MAP: smoothing prior'); xlabel('time');
        box off
    end
    
    subplot(2,2,4);  % post spike filter
    plot(Expt(e).Clu(CluSelect(curClu)).GLM.ML.iht,exp(Expt(e).Clu(CluSelect(curClu)).GLM.ML.ihbas*Expt(e).Clu(CluSelect(curClu)).GLM.ML.ihw),...
        Expt(e).Clu(CluSelect(curClu)).GLM.L2.iht, exp(Expt(e).Clu(CluSelect(curClu)).GLM.L2.ihbas*Expt(e).Clu(CluSelect(curClu)).GLM.L2.ihw), ...
        Expt(e).Clu(CluSelect(curClu)).GLM.Smooth.iht, exp(Expt(e).Clu(CluSelect(curClu)).GLM.Smooth.ihbas*Expt(e).Clu(CluSelect(curClu)).GLM.Smooth.ihw) ...
        ); axis tight;
    box off
ylabel('gain')
xlim([0 .050])
legend boxoff
    title('post-spike kernel');  xlabel('time after spike (s)');
    legend('ML','ridge','smooth');
    
end
