function yhat_t = gaintimecoursemodel(x, data)
% gain model with time course

a = x(1);
b = x(2);
c_L = x(3);
c_H = x(4);
d_L = x(5);
d_H = x(6);
tau = 1000; %x(7); % time constant
h_0 = x(8); % lag of exponential

z_t = data.z_t;
C_ht = data.C_ht;
[n_h, n_t] = size(C_ht);
dt = data.dt;

h = dt * ((n_h-1):-1:0)';

% old version of code, messier but the same result
% % lambda_h = repmat(exp(-h/tau),[1 size(C_ht,2)]);
% % kappa_h = lambda_h./ ...
% %          repmat(sum(lambda_h,1), [size(lambda_h, 1), 1]);

% cp_t = c_L + (c_H-c_L)*sum(kappa_h.*C_ht, 1);
% dp_t = d_L + (d_H-d_L)*sum(kappa_h.*C_ht, 1);

% exponential weighting with lag
h_dash = max(h-h_0, 0);
lambda_h = exp(-(h_dash)/tau);
% plot(-h_dash, lambda_h);
% drawnow;

% weighting function should sum to 1
kappa_h = lambda_h / sum(lambda_h);

% exponential weighting multiplied by contrast history
r_t = multiprod(C_ht, kappa_h, 1);


c_t = c_L + (c_H-c_L)*r_t;
d_t = d_L + (d_H-d_L)*r_t;

g = 1./(1+exp(-(z_t-c_t)./d_t));

yhat_t = a + b*g;

if isfield(data, 'pause');
  subplot(3,1,1);
  plot(data.C_ht(end,:));
  subplot(3,1,2);
  plot(c_t);
  subplot(3,1,3);
  plot(d_t);
  keyboard;
end
%keyboard
