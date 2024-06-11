function handle = label_in_corner(str, which_corner, offset_x, offset_y)

if ~exist('which_corner', 'var')
	which_corner = 'topleft';
end

if ~exist('offset_x', 'var')
	offset_x = 0.02;
end

if ~exist('offset_y', 'var')
	offset_y = 0.1;
end


if findstr(which_corner, 'bottom')
	y = 0 + offset_y;
	valign = 'bottom';
else
	y = 1 - offset_y;
	valign = 'top';
end

if findstr(which_corner, 'right')
	x = 1 - offset_x;
	halign = 'right';
else
	x = 0 + offset_x;
	halign = 'left';
end

xl = xlim;
if strcmp(get(gca, 'xdir'), 'reverse')
	xl = fliplr(xl);
end
xmin = xl(1);
xrange = xl(2)-xl(1);

yl = ylim;
if strcmp(get(gca, 'ydir'), 'reverse')
	yl = fliplr(yl);
end
ymin = yl(1);
yrange = yl(2)-yl(1);

handle = text(xmin+x*xrange, ymin+y*yrange, str);
set(handle, 'verticalalignment', valign, 'horizontalalignment', halign);