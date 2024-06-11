function h = subplotbw(m,n,p,separation)

if ~exist('separation','var')
  separation = .1;
end

prop = 1-separation;

margin = .1;

xnum = mod(p-1,n)+1;
ynum = floor((p-1)/n)+1;

xwid = prop/n*(1-margin);
ywid = prop/m*(1-margin);

xmin = margin/2 + (xnum-(1-margin))/n*(1-margin) + ((1-margin)/n-xwid)/2;
ymin = margin/2 + (1-margin)-(ynum)/m*(1-margin) + ((1-margin)/m-ywid)/2;
h = subplot('position',[xmin ymin xwid ywid]);