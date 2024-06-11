function [y_dt,y_tr] = detrend(y,order)
% function [y_dt,y_tr] = detrend(y,order)
% remove polynomial trend from time series data
% returns y_dt == detrended data
%         y_tr == trend itself
% bw 07 jun 2005

if ~exist('order','var')
  order = 5;
end

y = shiftdim(y);

mn = mean(y);
sd = std(y);
y_st = (y-mn)/sd;

x_st = [1:length(y_st)]';
x_st = (x_st-mean(x_st))/std(x_st);

p = polyfit(x_st,y_st,order);
y_tr = polyval(p,x_st)*sd+mn;

y_dt = y - y_tr;

y_dt = reshape(y_dt,size(y));
y_tr = reshape(y_tr,size(y));