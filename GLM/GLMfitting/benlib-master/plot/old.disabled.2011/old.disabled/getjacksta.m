function sta = getjacksta(stim,resp,lags,njacks,thresh)
% function kernel = getjacksta(stim,resp,lags)
% bw mar 2004
% computes the spike-triggered average, given:
% stim: a 2D matrix of stimuli, mxn where m is the 
%       number of pixels and n is the number of stimuli
% resp: a column vector (nx1) of responses
% lags: a column vector (px1) of lags (in frames)
% kernel is a 2D matrix containing the STA, with one column per lag

display=1;

if size(resp,2)>1 | size(lags,2)>1
  fprintf('resp and lags should be column vectors\n');
  kernel = [];
  return;
end

if size(resp,1)~=size(stim,2)
  fprintf('don''t know what to do when resp length isn''t equal to number of stimuli\n');
  kernel = [];
  return;
end  

resplen = length(resp);
nanlen = ceil(resplen/(njacks+1));

staj = zeros(size(stim,1),length(lags),njacks);

fprintf(['Calculating ' num2str(njacks) ' jackknife STAs']);
for jack = 1:njacks
  nanstart = (jack-1)*nanlen+1;
  nanend   = min(nanstart+nanlen-1,resplen);
  nanresp = resp;
  nanresp(nanstart:nanend) = nan;
  staj(:,:,jack) = getsta(stim,nanresp,lags);
  fprintf('.');
end
fprintf('\n');

stamn = mean(staj,3);
stasd = std(staj,0,3);
warning off MATLAB:divideByZero;
sigtonoise = abs(stamn./stasd);
warning on MATLAB:divideByZero;
sigtonoise(find(isnan(sigtonoise)))=max(sigtonoise(:));

if display==1
  subplot(3,1,1);
  histogram(stamn(:));
  title('Mean');
  subplot(3,1,2);
  histogram(stasd(:));
  title('Standard deviation');
  subplot(3,1,3);
  histogram(sigtonoise(:));
  title('Signal to noise');
end

nanstart = njacks*nanlen+1;
nanend   = min(nanstart+nanlen-1,resplen);

thresholds=logspace(-2,0,5)*max(sigtonoise(:));
staj = zeros(size(stim,1),length(lags),length(thresholds));
fprintf(['Trying ' num2str(length(thresholds)) ' shrinkage thresholds ']);
for thnum=1:length(thresholds)
  thresh=thresholds(thnum);
  fprintf([num2str(thresh) ' ']);
  stath(:,:,thnum) = stamn.*(sigtonoise>=thresh);
  testresp = getresp(stim(:,nanstart:nanend),stath(:,:,thnum),lags)';
  
  if min(testresp) ~= max(testresp)
    cctmp = corrcoef(resp(nanstart:nanend),testresp);
    cc(thnum)= cctmp(1,2);
  else
    cc(thnum) = -1;
  end
  
  %fprintf('.');
end
fprintf('\n');

a = gcf;
figure(5);
plot(thresholds,cc);
figure(a);
ccmax = max(cc(:));
bestthnum = find(cc==ccmax);
bestthnum = bestthnum(end);
bestthresh = thresholds(bestthnum);
fprintf(['Best threshold = ' num2str(bestthresh) '; cc = ' num2str(ccmax) '\n']);
sta = stath(:,:,bestthnum);