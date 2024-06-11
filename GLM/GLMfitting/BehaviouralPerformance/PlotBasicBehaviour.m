function []=PlotBasicBehaviour(Beh)


figure(300000)
subplot(2,4,[1 2])
plot(Beh.conds, Beh.Total.Missrate,'b','linewidth',2)
hold on
plot(Beh.conds, Beh.Total.ELrate,'r','linewidth',2)
plot(Beh.conds, Beh.Total.PerfTotal,'g','linewidth',2)
plot(Beh.conds, Beh.Total.PerfNoEarly,'k','linewidth',2)
box off
legend('Miss','Early Lick','Total Correct','Completed Correct')
legend boxoff
ylabel('Rate')
xlabel('Change TF')
set(gca,'FontSize',11)
title('total performance')

subplot(2,4,3)
plot(Beh.conds, Beh.Early.Missrate,'b','linewidth',2)
hold on
plot(Beh.conds, Beh.Early.ELrate,'r','linewidth',2)
plot(Beh.conds, Beh.Early.PerfTotal,'g','linewidth',2)
plot(Beh.conds, Beh.Early.PerfNoEarly,'k','linewidth',2)
box off
title('early block')
ylabel('Rate')
xlabel('Change TF')
set(gca,'FontSize',11)

subplot(2,4,4)
plot(Beh.conds, Beh.Late.Missrate,'b','linewidth',2)
hold on
plot(Beh.conds, Beh.Late.ELrate,'r','linewidth',2)
plot(Beh.conds, Beh.Late.PerfTotal,'g','linewidth',2)
plot(Beh.conds, Beh.Late.PerfNoEarly,'k','linewidth',2)
box off
ylabel('Rate')
xlabel('Change TF')
set(gca,'FontSize',11)
title('late block')
% 

subplot(2,4,[5 6])
errorbar(Beh.conds,Beh.Early.CondRT,Beh.Early.CondRT95CI,'b','linewidth',2)
hold on
errorbar(Beh.conds,Beh.Late.CondRT,Beh.Late.CondRT95CI,'r','linewidth',2)
box off
xlabel('Change TF')
ylabel('RT (s)')
legend('Early','Late')
title('Reaction time')
legend boxoff
set(gca,'FontSize',11)

subplot(2,4,[7 8])
plot([0:0.5:20],histc(Beh.Early.EL_RT,[0:0.5:20]),'b','linewidth',2)
hold on
plot([0:0.5:20],histc(Beh.Late.EL_RT,[0:0.5:20]),'r','linewidth',2)
xlim([0 16])
box off
title('Early lick time')

legend('Early','Late')
legend boxoff
xlabel('Time from start (s)')
set(gca,'FontSize',11)
