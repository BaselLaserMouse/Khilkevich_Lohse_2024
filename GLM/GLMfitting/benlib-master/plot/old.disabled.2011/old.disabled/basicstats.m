function basicstats(respfile)

clf;

% hardcoded! fixme!
hz = 60;
ms = 1000/hz;

r = respload(respfile,'r');
r = compact_raster_matrix3(r);

spikes_mn = nanmean(r');
spikes_var = nanstd(r').^2;

psth = nanmean(r'*hz);
psth_sem = nanstd(r'*hz)./sqrt(sum(isfinite(r'*hz)));


subplot(3,1,1);
plotrasterbw(r);
colormap(gray(256));
xlabel('Frame #');
ylabel('Trial #');
yl = get(gca,'YTickLabel');
len = length(yl);
set(gca,'YTickLabel',ceil([0:(size(r,2)/(len-1)):size(r,2)]));

fnd = findstr(respfile,'/');
if isempty(fnd)
  fnd = 0;
end

title(respfile(fnd(end)+1:end));

length(psth)
subplot(3,1,2);
plot(1:ms:length(psth)*ms,psth,'b');
hold on;
plot(1:ms:length(psth)*ms,psth-psth_sem,'r:');
plot(1:ms:length(psth)*ms,psth+psth_sem,'r:');
hold off;
xlabel('Time/ms (assuming 60Hz frame rate)');
ylabel('Firing rate /Hz');

subplot(3,2,5);
histogram(psth,15);
xlabel('Firing rate/Hz (assuming 60Hz frame rate)');
ylabel('Frequency / # frames');

mn = mean(psth);

hold on;
lim = axis;
line([mn mn],[lim(3) lim(4)]);
text(mn+2,lim(4)-10,['Mean = ' num2str(mn)]);
hold off;

subplot(3,2,6);
plot(spikes_mn,spikes_var,'.');
hold on;
p_mx = max(spikes_mn);
plot([0 p_mx],[0 p_mx],'r:');
text(p_mx,p_mx,'\sigma^2/\mu=1');
plot([0 p_mx],2*[0 p_mx],'r:');
text(p_mx,p_mx*2,'\sigma^2/\mu=2');
b = regress(spikes_var',spikes_mn');
plot([0 p_mx],[0 b*p_mx],'g:');
text(p_mx,b*p_mx,['\sigma^2/\mu=' num2str(b)]);
hold off;
xlabel('Mean spikes per frame');
ylabel('Variance of spikes per frame');
