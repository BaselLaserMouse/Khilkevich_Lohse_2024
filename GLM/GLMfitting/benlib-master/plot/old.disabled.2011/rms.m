function y = rms(x)

x = x(:);
y = sqrt(mean(x.^2));