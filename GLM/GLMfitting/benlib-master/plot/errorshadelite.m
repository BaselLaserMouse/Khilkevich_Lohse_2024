function [shading] = errorshade(x,y,yl,yu)

%line = plot(x,y,'k-');
%hold on;
shading = patch([x fliplr(x)],[y-yl fliplr(y+yu)],[.7 .7 .7]);
set(shading,'edgecolor','none');
%hold on;
%line = plot(x,y,'k-');
%hold off;
