function legendspacing(h, xAdjust, yAdjust, fontSize, lineAdjust)
% adjust the x and y spacing, and font size, of a legend h
% Surrounding box is also turned off (since it will no longer fit). You can draw
% a new one with rectangle(...)
% 
% xAdjust and yAdjust are amounts to increase (or if -ve, decrease) spacing
% fontSize (optional) is an absolute value
% lineAdjust affects the length of lines in the legend
%
% NB the legend MUST be created with [l,i,p,s] = legend(...), not just l = legend(...)
% I don't know why!
%
% e.g. :
% d(1) = plot(rand(1,10), rand(1,10), 'ok'); hold on;
% d(2) = plot(rand(1,10), rand(1,10), '-r');
% [l,icons,plots,str]=legend(d, {'one'; 'two'});hold off;
% legendspacing(l, -.01, -.01, 8);

strings = get(h, 'ItemText')
icons = get(h, 'ItemTokens')
n = length(strings)

% adjust x spacing between lines and text
for ii = 1:length(icons)
	icons(ii).XData = 	icons(ii).XData - xAdjust;
end

% adjust y spacing between lines
if nargin>2
	for ii = 1:n
		icons(ii*2-1).YData = icons(ii*2-1).YData - ii*yAdjust;
		icons(ii*2).YData = icons(ii*2).YData - ii*yAdjust;
		strings(ii).Position(2) = strings(ii).Position(2) - ii*yAdjust;
	end
end

% set font size
if nargin>3
	for ii = 1:length(strings)
		strings(ii).FontSize = fontSize;
	end
end

if nargin>4
	for ii = 1:length(icons)
		icons(ii).XData(1) = icons(ii).XData(1) -lineAdjust;
	end
end

set(h, 'box', 'off');

% for s = 1:length(icons) %numel(data.stimdesc)
% 	if strcmp(class(icons(s)), 'matlab.graphics.primitive.Text')
% 		icons(s).FontSize = legendfontsize; 
% 	end
% 	%icons(numel(data.stimdesc)+2*s).MarkerSize = legendmarkersize;
% end