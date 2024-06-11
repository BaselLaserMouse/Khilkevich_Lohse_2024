function kernel = getsta(stim,resp,lags)
% function kernel = getsta(stim,resp,lags)
% bw mar 2004
% computes the spike-triggered average, given:
% stim: a 2D matrix of stimuli, mxn where m is the 
%       number of pixels and n is the number of stimuli
% resp: a column vector (nx1) of responses
% lags: a column vector (px1) of lags (in frames)
% kernel is a 2D matrix containing the STA, with one column per lag

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

% specify where the response is in the original resp matrix, for 
% every lag/frame combination
lagtimes = repmat((1:length(resp))',[1 length(lags)]);
lagtimes = lagtimes + repmat(lags',[length(resp) 1]);

% note we shouldn't really wrap around here
lagtimes = mod(lagtimes-1,length(resp))+1;

% get the appropriate responses into a framesxlags matrix
lagged_resps = resp(lagtimes);

% nans should be translated into 0s for the purposes of summing
% (so they don't contribute to the matrix multiplication)...
z_l_r = lagged_resps;
z_l_r(find(isnan(z_l_r)))=0;

% ...but should still be considered nans for the purposes of
% dividing by the number of responses to get the mean.
numresps = nansum(lagged_resps);

% get the sum
sm = stim * z_l_r;

% normalise to get the average
kernel = sm./repmat(numresps,[size(sm,1),1]);
