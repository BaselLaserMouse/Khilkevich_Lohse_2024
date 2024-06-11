function [trend, points, lines] = plotfloatssinkers(x,points_y,trend_y)

lines = nan(1,length(x));
for ii = 1:length(x)
  lines(ii)=line([x(ii) x(ii)], [trend_y(ii) points_y(ii)]);
  if trend_y(ii)>points_y(ii)
    set(lines(ii),'color',[0 1 0]);
  else
    set(lines(ii),'color',[1 0 0]);
  end
end

hold on;
trend = plot(x,trend_y,'k-');
points = plot(x,points_y,'ko');
hold off;


