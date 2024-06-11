function histcolor(arg1, arg2)

if nargin==1
	color = arg1;
elseif nargin==2
	axnum = arg1;
	color = arg2;
end

axes(gca);

h = findobj(gca,'Type','patch');
set(h,'FaceColor', color);
