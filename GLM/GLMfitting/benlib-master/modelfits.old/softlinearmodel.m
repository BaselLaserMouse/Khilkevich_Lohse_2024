function yhat_t = softlinearmodel(x, data)
% function yhat_t = lnmodel(x, data)
% 
% Calculate soft threshold linear LN model
% 
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

a = x(1); % y-offset
b = x(2); % slope
c = x(3); % x-offset
d = x(4); % sharpness of transition

if isstruct(data)
  z_t = data.z_t;
else
  z_t = data;
end

%yhat_t = a + b.*log(1+exp(z_t-c));
%yhat_t = a + b./d.*log(1+exp(d*(z_t-c)));

w = d*(z_t-c);
exp_tmp = exp(w);
log_tmp = log(1+exp_tmp);

% Replace log_tmp with numerically stable version if w>700
% (because exp(710) is Inf.
% log_tmp = log(1+exp_tmp) = log(1+exp(w))
% For large values, we are in the linear regime, so
% our numerically stable approximation is just w itself:
log_tmp(w>700) = w(w>700);

yhat_t = a + b./d.*log_tmp;
