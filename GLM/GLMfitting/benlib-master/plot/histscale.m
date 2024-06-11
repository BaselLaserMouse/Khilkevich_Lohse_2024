function histscale(arg1, arg2)

if nargin==0
	scale = 1.2;
elseif nargin==1
	scale = arg1;
elseif nargin==2
	axnum = arg1;
	scale = arg2
end

axes(gca);

c = get(gca, 'children');
ydata = max(get(c, 'ydata'));
y_max = max(abs(ydata));
ylim([0 y_max*scale]);
