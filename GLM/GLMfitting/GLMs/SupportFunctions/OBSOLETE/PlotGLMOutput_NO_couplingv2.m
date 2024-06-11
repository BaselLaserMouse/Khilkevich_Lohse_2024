
%%  Plot
cd('/mnt/data/mlohse/GLMoutput2DimPOSTSPIKE')
Files=dir

for curClu=1:(length(Files)-2)
    %colormap=redblue
    load(Files(curClu+2).name)
    figure(curClu)
    clf
    Temp=['Filters for unit ' Files(curClu+2).name];
    set(gcf,'Name',Temp,'NumberTitle','off')
    clear Temp
    subplot(3,3,1);  % ML filter
    if size(GLM.Init.k,2)>1
        imagesc(GLM.ML.k');
    else
        plot([1:size(GLM.Init.ktbas,1)].*GLM.Init.dtStim,GLM.ML.k,'linewidth',1.75);xlabel('time');
        box off
   end
    title('ML estimate'); ylabel('time');
    
    subplot(3,3,2); % Filter with L2
   if size(GLM.Init.k,2)>1
        imagesc(GLM.L2.k'); title('MAP: ridge prior'); xlabel('space'); ylabel('time');
    else
        plot([1:size(GLM.Init.ktbas,1)].*GLM.Init.dtStim,GLM.L2.k,'linewidth',1.75); title('MAP: ridge prior'); xlabel('time')
        box off
   end
    
    subplot(3,3,3); % Filter with smoothing prior
    if size(GLM.Init.k,2)>1
        imagesc(GLM.Smooth.k'); title('MAP: smoothing prior'); xlabel('space');ylabel('time');
    else
        plot([1:size(GLM.Init.ktbas,1)].*GLM.Init.dtStim,GLM.Smooth.k,'linewidth',1.75); title('MAP: smoothing prior'); xlabel('time');
        box off
    end
    
    subplot(3,3,[4:6]);  % post spike filter
    plot(GLM.ML.iht,exp(GLM.ML.ihbas*GLM.ML.ihw),...
        GLM.L2.iht, exp(GLM.L2.ihbas*GLM.L2.ihw), ...
        GLM.Smooth.iht, exp(GLM.Smooth.ihbas*GLM.Smooth.ihw) ...
        ); axis tight;
    box off
    ylabel('gain')
    xlim([0 .150])
    legend boxoff
    title('post-spike kernel');  xlabel('time after spike (s)');
    legend('ML','ridge','smooth');
    
%     subplot(3,3,[7]);  % coupling filter
%     plot(GLM.ML.iht,exp(GLM.ML.ihbas2*GLM.ML.ihw2)); axis tight;
%     box off
%     ylabel('gain')
%     xlim([0 .050])
%     legend off
%     xlabel('time after spike (s)');
%     title('coupling kernels: ML');
%     
%     subplot(3,3,[8]);  % coupling filter
%     plot(GLM.L2.iht,exp(GLM.L2.ihbas2*GLM.L2.ihw2)); axis tight;
%     box off
%     ylabel('gain')
%     xlim([0 .050])
%     legend off
%     xlabel('time after spike (s)');
%     title('coupling kernels: ridge');
%     
%     subplot(3,3,[9]);  % coupling filter
%     plot(GLM.Smooth.iht,exp(GLM.Smooth.ihbas2*GLM.Smooth.ihw2)); axis tight;
%     box off
%     ylabel('gain')
%     xlim([0 .050])
%     legend off
%     xlabel('time after spike (s)');
%     title('coupling kernels: smooth');
    clear GLM
    
    
end
% 
% %%
% load('GLM_PostSpikeandStimOnlyAK_1108135_S06_Clu5.mat')
% figure;
% plot(GLM.ML.Ih,'b');
% hold on;plot(GLM.ML.Itot,'b');
% hold on;plot((GLM.ML.Istm*20)-50,'r');
% hold on;plot(GLM.ML.Ih,'g');
% %hold on;plot(GLM.Smooth.Icpl,'y');
% hold on;scatter(1:length(GLM.Init.sps),GLM.Init.sps,'k.')
% xlim([0 35000])