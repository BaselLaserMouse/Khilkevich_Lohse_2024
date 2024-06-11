function h = subplottight(m,n,p,separation, margin)

if ~exist('separation','var')
  separation = .1;
end

if length(separation)==1
  separation = [separation separation];
end

if ~exist('margin', 'var')
	margin = .05;
end

if length(margin)==1
  margin = [margin margin];
end


xnum = mod(p-1,n)+1;
ynum = floor((p-1)/n)+1;

xboxwid = (1-2*margin(1))/n;
yboxwid = (1-2*margin(2))/m;

xplotwid = xboxwid*(1-separation(1));
yplotwid = yboxwid*(1-separation(2));

xboxmargin = (xboxwid-xplotwid)/2;
yboxmargin = (yboxwid-yplotwid)/2;

xmin = margin(1) + xboxwid*(xnum-1) + xboxmargin;
ymin = 1 - (margin(2) + yboxwid*(m-ynum) + yboxmargin);

h = subplot('position',[xmin 1-ymin xplotwid yplotwid]);
