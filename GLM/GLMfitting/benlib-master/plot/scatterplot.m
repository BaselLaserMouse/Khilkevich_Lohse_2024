function p = scatterplot(varargin)

colours = ...
[228,26,28 ; ...
    55,126,184; ...
    77,175,74; ...
    152,78,163; ...
    255,127,0; ...
    255,255,51; ...
    166,86,40; ...
    ]/255;

symbols = 'xo+*sqdv^>ph';

p = [];
n = 0;
for ii = 1:2:length(varargin)
    n = n +1;
    p(n) = plot(varargin{ii}, varargin{ii+1}, symbols(n), 'color', colours(n,:), 'markersize', 8);
    hold on;
end

xl = xlim;
yl = ylim;

l = [min(xl(1), yl(1)) max(xl(2), yl(2))];

plot([l(1)-1000 l(2)+1000], [l(1)-1000 l(2)+1000], 'k-', 'linewidth', 2);
xlim(xl);
ylim(yl);
hold off;

xlim(l);
ylim(l);

axis square;
