function smap = spotmap(pypefile, varargin)

% smap = spotmap(pypefile, ..opts..)
%  pypefile = name of pype data file ([] for last plotted file)
%  opts:
%    'smooth' or 'nosmooth' -> enable/disable smoothing (default=nosmooth)
%    'contour', %value -> set marked contour value (default=0.50)
%    'plot', 'noplot' -> disable plotting (get contour only)
%    'fit', 'notfit' -> set rf fitting.
%    'lat' -> set latency
%
%  returns smap data structure with members:
%   smap.off	off contour
%   smap.on 	on contour
%   smap.all	composite contour (on+off)
%   smap.{xmin,xmax,ymin,ymax} 
%		bounds of spotmapped region
%   smap.g_off	off symmetric gaussian fit
%   smap.g_on	on symmetric gaussian fit
%   smap.g_all	composite symmetric gaussian fit
%
% Sun Mar  5 23:16:14 2000 mazer 

l = jls(pypefile);
if length(l) > 1
  smap = [];
  for i=1:length(l)
    clf;
    s = spotmap(char(l(i)), varargin{:});
    s.file = char(l(i));
    smap = [smap s];
    getframe;
    fullpage;
    print -dpsc
  end
  return
end

smooth=0;
noplot=0;
contourval=0.50;
plotpos = [];

narg = 1;
latency = 0;
winsize=0;
while narg <= length(varargin)
  switch varargin{narg}
   case 'winsize'
    winsize = varargin{narg + 1};
    narg = narg + 1;
   case 'lat'
    latency = varargin{narg + 1};
    narg = narg + 1;
   case 'smooth'
    smooth=1.0;
   case 'smoothby'
    smooth = varargin{narg + 1};
    narg = narg + 1;
   case 'nosmooth'
    smooth=0;
   case 'contour'
    contourval = varargin{narg + 1};
    narg = narg + 1;
   case 'plot'
    noplot = 0;
   case 'noplot'
    noplot = 1;
   case 'subplot'
    plotpos = varargin{narg + 1};
    narg = narg + 1;
    if length(plotpos) < 12
      error(sprintf('plotpos must be len=12'));
    end
   otherwise
    error(sprintf('unknown option: %s', varargin{narg}));
  end
  narg = narg + 1;
end
[t, psth, spsth, fdur, fgap] = spotmap_hist(pypefile);

if isnan(latency)
  % try to automatically calc latency from spotmap hist..
  % say minimum latency is 20ms..
  [l, w] = estlat(t, spsth, 20);
  latency = round(l);
  autolat = 'AUTO';
else
  autolat = '';
end

if winsize == 0 | isnan(winsize)
  winsize = floor((fdur(1)-fdur(2)) + fgap(1)-fgap(2));
end

if ~noplot
  subplot(4,1,4);
  plot(t, spsth, 'k-');
  axis tight
  xlabel('Time (ms)');
  ylabel('s/s');
  
  line([0 0], [0 max(spsth)/2]);
  line([fdur(1) fdur(1)], [0 max(spsth)/2]);
  line([fdur(1)+fgap(1) fdur(1)+fgap(1)], [0 max(spsth)/2]);
  
  set(line([latency latency], [max(spsth)/2 max(spsth)]), 'color', 'r');
  set(line([latency+winsize latency+winsize], ...
	   [max(spsth)/2 max(spsth)]), 'color', 'r');
  title(sprintf('[%d-%d ms]%s', round(latency), round(winsize),...
		autolat));
end

if ~isempty(pypefile)
  c = sprintf(['pypenv Xspotmap %s -latency=%d ' ...
	       '-winsize=%d -dump >/tmp/%s-tmp.asc'], ...
	       pypefile, latency, winsize, getenv('LOGNAME'));
  unix(c);
  f = basename(pypefile);
else
  f = 'lastfile';
end

s=load(sprintf('/tmp/%s-tmp.asc', getenv('LOGNAME')));
l = length(s);

off = s(find(s(:,1) == 0), 2:end);
on = s(find(s(:,1) == 1), 2:end);
all = s(find(s(:,1) == 2), 2:end);

smap.xmin = min(s(:,2));
smap.xmax = max(s(:,2));
smap.ymin = min(s(:,3));
smap.ymax = max(s(:,3));

smap.latency = latency;
smap.winsize = winsize;

x0=off(:,1); y0=off(:,2); z0=off(:,3);
[x, y, z1, cx, cy] = priv_xyz(x0, y0, z0, smooth, 1, contourval, 0);
x0=on(:,1); y0=on(:,2); z0=on(:,3);
[x, y, z2, cx, cy] = priv_xyz(x0, y0, z0, smooth, 1, contourval, 0);
x0=all(:,1); y0=all(:,2); z0=all(:,3);
[x, y, z3, cx, cy] = priv_xyz(x0, y0, z0, smooth, 1, contourval, 0);
z = [z1(:) z2(:) z3(:)];
zmax = max(z(:));



%%%%%%%% OFF %%%%%%%%%%
x0=off(:,1);
y0=off(:,2);
z0=off(:,3);

[x, y, z, cx, cy] = priv_xyz(x0, y0, z0, smooth, 1, contourval, zmax);
q = fit_circ('fit',cx,cy);
smap.c_off.x = q(1);
smap.c_off.y = q(2);
smap.c_off.r = q(3);
if ~noplot
  if isempty(plotpos)
    subplot(4,2,1);
  else
    mysubplot(plotpos(1:4));
  end
  priv_xyz(x0, y0, z0, smooth, 0, contourval, zmax);
  %colormap(blueyellow);
  colormap(hotcold(1));
  [a,b]=meshgrid(x0,y0);
  colorbar;
  %title({sprintf('{\\bf%s}', f), 'Off Response (sp/sec)'});
  title(sprintf('{\\bf%s}', f));
  ylabel('OFF');
  hold on;
  set(plot(smap.c_off.x, smap.c_off.y, 'g+'), ...
      'MarkerSize', 10);
  circle([smap.c_off.x smap.c_off.y], smap.c_off.r, 'w-');
  plot(a, b, 'k.');
  hold off;
  %squareup;
  axis image
end


%%%%%%%% ON %%%%%%%%%%
x0=on(:,1);
y0=on(:,2);
z0=on(:,3);

[x, y, z, cx, cy] = priv_xyz(x0, y0, z0, smooth, 1, contourval, zmax);
q = fit_circ('fit',cx,cy);
smap.c_on.x = q(1);
smap.c_on.y = q(2);
smap.c_on.r = q(3);

if ~noplot
  if isempty(plotpos)
    subplot(4,2,3);
  else
    mysubplot(plotpos(5:8));
  end
  priv_xyz(x0, y0, z0, smooth, 0, contourval, zmax);
  %colormap(blueyellow);
  colormap(hotcold(1));
  [a,b]=meshgrid(x0,y0);
  colorbar;
  %title({sprintf('{\\bf%s}', f), 'On Response (sp/sec)'});
  ylabel('ON');
  hold on;
  set(plot(smap.c_on.x, smap.c_on.y, 'g+'), ...
      'MarkerSize', 10);
  circle([smap.c_on.x smap.c_on.y], smap.c_on.r, 'w-');
  plot(a, b, 'k.');
  hold off;
  %squareup;
  axis image
end


%%%%%%%% ALL %%%%%%%%%%
x0=all(:,1);
y0=all(:,2);
z0=all(:,3);

[x, y, z, cx, cy] = priv_xyz(x0, y0, z0, smooth, 1, contourval, zmax);
q = fit_circ('fit',cx,cy);
smap.c_all.x = q(1);
smap.c_all.y = q(2);
smap.c_all.r = q(3);

if ~noplot
  if isempty(plotpos)
    subplot(4,2,5);
  else
    mysubplot(plotpos(9:12));
  end
  priv_xyz(x0, y0, z0, smooth, 0, contourval, zmax);
  %colormap(blueyellow);
  colormap(hotcold(1));
  [a,b]=meshgrid(x0,y0);
  colorbar;
  %title({sprintf('{\\bf%s}', f), 'All Response (sp/sec)'});
  ylabel('COMP');
  hold on;
  set(plot(smap.c_all.x, smap.c_all.y, 'g+'), ...
      'MarkerSize', 10);
  circle([smap.c_all.x smap.c_all.y], smap.c_all.r, 'w-');
  plot(a, b, 'k.');
  hold off;
  %squareup;
  axis image
end

% export unsmoothed ALL spotmap
[smap.allx, smap.ally, smap.allz, crapx, crapy] = priv_xyz(x0, y0, z0, 0, 1, contourval, zmax);

if ~noplot & isempty(plotpos)
  subplot(4,2,2);
  cla;
  axis off;
  text(0, 0.5, { ...
      sprintf('{\\bf OFF (pixels)}'), ...
      sprintf('x: %.0f', smap.c_off.x), ...
      sprintf('y: %.0f', smap.c_off.y), ...
      sprintf('d: %.0f', (smap.c_off.x^2+smap.c_off.y^2)^0.5), ...
      sprintf('s: %.0f', smap.c_off.r), ...
      sprintf('cont=%.0f%%max', contourval*100), ...
      sprintf('smooth=%.1f', smooth)});
  subplot(4,2,4); axis off;
  cla;
  text(0, 0.5, { ...
      sprintf('{\\bf ON (pixels)}'), ...
      sprintf('x: %.0f', smap.c_on.x), ...
      sprintf('y: %.0f', smap.c_on.y), ...
      sprintf('d: %.0f', (smap.c_on.x^2+smap.c_on.y^2)^0.5), ...
      sprintf('s: %.0f', smap.c_on.r), ...
      sprintf('cont=%.0f%%max', contourval*100), ...
      sprintf('smooth=%.1f', smooth)});
  subplot(4,2,6); axis off;
  cla;
  text(0, 0.5, { ...
      sprintf('{\\bf ALL (pixels)}'), ...
      sprintf('x: %.0f', smap.c_all.x), ...
      sprintf('y: %.0f', smap.c_all.y), ...
      sprintf('d: %.0f', (smap.c_all.x^2+smap.c_all.y^2)^0.5), ...
      sprintf('s: %.0f', smap.c_all.r), ...
      sprintf('cont=%.0f%%max', contourval*100), ...
      sprintf('smooth=%.1f', smooth)});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [newx, newy, zi, cx, cy] = priv_xyz(x, y, z, ...
					     smooth, noplot, p, zmax)

xv = unique(sort(x));
yv = unique(sort(y));

newx = (min(xv):max(diff(xv)):max(xv));
newy = (min(yv):max(diff(yv)):max(yv));

[xi,yi]=meshgrid(newx, newy);
zi = griddata(x,y,z,xi,yi);

if smooth > 0
  zi = smooth2d(zi, 0, 0, smooth);
end

if ~noplot
  contourf(xi, yi, zi, 10);
  caxis([0 zmax]);
end

z = zi - min(zi(:));
z = z ./ max(z(:));
c = contourc(newx, newy, z, [p p]);
[cx,cy]=contour2points(c);
if ~noplot
  hold on;
  l = plot(cx, cy, 'ro');
  set(l, 'MarkerSize', 5, 'MarkerFaceColor', 'y', 'MarkerEdgeCOlor', 'y');
  hold off;
end



