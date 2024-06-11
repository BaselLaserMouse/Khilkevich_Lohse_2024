function [trend, points, patches, lines] = plotfloatssinkers(x,points_y,trend_y)

x = x(:)'; %% eeep -- the code below assumes that x is a row and y is a col. gross.
points_y = points_y(:);
trend_y = trend_y(:);


trend = plot(x,trend_y,'k-');

hold on;
points = plot(x,points_y,'r-');
d = [sign(trend_y-points_y); 0];
f = find(diff(d)~=0);
s = d(f+1);

patches = nan(length(s)-1);
for ii = 1:length(s)-1
  patch_x = [x(f(ii):f(ii+1)) x(f(ii+1):-1:f(ii))]';
  patch_y = [points_y(f(ii):f(ii+1)); trend_y(f(ii+1):-1:f(ii))];
  if s(ii)==1
    col = [0 1 0];
  else
    col = [1 0 0];
  end
  patches(ii) = patch(patch_x,patch_y,col);
end

lines = nan(1,length(x));
for ii = 1:length(x)
  lines(ii)=line([x(ii) x(ii)], [trend_y(ii) points_y(ii)]);
  set(lines(ii),'color',[0 0 0]);
end

trend = plot(x,trend_y,'k-');
points = plot(x,points_y,'k.');
hold off;


