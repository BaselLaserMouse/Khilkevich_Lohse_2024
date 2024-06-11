function stats = dbbasicstats(in)

stats = [];

if exist(in,'file')
  r = respload(in,'r');
  fnd = findstr(in,'/');
  if isempty(fnd)
    fnd = 0;
  end
  nm = in(fnd(end)+1:end);
else
  params = getnrparams(in);
  params.resploadparms = {'r',1,1,0};
  r = xcloadresp(params.times(3).fileidx,params.times(3).start, ...
		 params.times(3).stop,params);
  nm = in;
end

% hardcoded! fixme!
hz = 60;
ms = 1000/hz;

%r = respload(respfile,'r');

rc = compact_raster_matrix3(r);
if size(rc,2) < 7
  disp([in ': not enough trials! Quitting...']);
  return;
end

spikes_mn = nanmean(r');
spikes_var = nanstd(r').^2;

psth = nanmean(r'*hz);
psth_sem = nanstd(r'*hz)./sqrt(sum(isfinite(r'*hz)));


subplot(3,1,1);
plotrasterbw(rc);
colormap(gray(256));
xlabel('Frame #');
ylabel('Trial #');
yl = get(gca,'YTickLabel');
len = length(yl);
set(gca,'YTickLabel',ceil([0:(size(r,2)/(len-1)):size(r,2)]));

title(nm);

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

mn = nanmean(psth);
sp = vinjesparseness(psth);
k = kurtosis([psth -psth],0);

hold on;
lim = axis;
line([mn mn],[lim(3) lim(4)]);
title(['Mean = ' num2str(mn) '; sp = ' num2str(sp) '; k = ' num2str(k)]);
hold off;

ds = 10;
r_resamp = 0;
for ii = 1:ds
  r_resamp = r_resamp + r(ii:ds:end,:);
end

rspikes_mn = nanmean(r_resamp');
rspikes_var = nanstd(r_resamp').^2;

subplot(3,2,6);
plot(rspikes_mn,rspikes_var,'.');
hold on;
p_mx = max(rspikes_mn);
plot([0 p_mx],[0 p_mx],'r:');
text(p_mx,p_mx,'\sigma^2/\mu=1');
plot([0 p_mx],2*[0 p_mx],'r:');
text(p_mx,p_mx*2,'\sigma^2/\mu=2');
b = regress(rspikes_var',rspikes_mn');
plot([0 p_mx],[0 b*p_mx],'g:');
text(p_mx,b*p_mx,['\sigma^2/\mu=' num2str(b)]);
hold off;
xlabel('Mean spikes per frame');
ylabel('Variance of spikes per frame');

rc = compact_raster_matrix3(r);

raster_xc = zeros(size(rc,2));
size(rc)
size(raster_xc)
for ii = 1:size(rc,2)
  for jj = 1:size(rc,2)
    raster_xc(ii,jj) = nanxc(rc(:,ii)',rc(:,jj)');
  end
end

raster_xc_with_mean = zeros(1,size(rc,2));

for ii = 1:size(rc,2)
  raster_xc_with_mean(ii) = nanxc(rc(:,ii),spikes_mn');
end

rc1 = rc(:,1:2:end);
rc2 = rc(:,2:2:end);

mn1 = nanmean(rc1')';
mn2 = nanmean(rc2')';
raster_xc_halves = nanxc(mn1,mn2);

stats.spikecount = nansum(psth);
stats.sparseness = sp;
stats.kurtosis   = k;
stats.fano       = b;
stats.raster_xc = raster_xc;
stats.raster_xc_with_mean = raster_xc_with_mean;
stats.raster_xc_halves = raster_xc_halves;