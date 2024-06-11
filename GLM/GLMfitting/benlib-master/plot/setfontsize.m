function setFontSize(varargin)
% set font size for all subplots in current figure
% one argument --> all text will be set to this size
% OR three arguments with text size for text, axis labels, legends

if nargin==1
    textSize = varargin{1};
    axisSize = varargin{1};
    legendSize = varargin{1};
else
    textSize = varargin{1};
    axisSize = varargin{2};
    legendSize = varargin{3};
end

allText = findall(gcf, 'type', 'text');
allAxes = findall(gcf, 'type', 'axes');
allLegend = findall(gcf, 'tag', 'legend');

for ii = 1:length(allText)
    set(allText(ii),'FontSize',textSize);
end

for ii = 1:length(allAxes)
    set(allAxes(ii),'FontSize',axisSize);
end    

for ii = 1:length(allLegend)
    set(allLegend(ii),'FontSize',legendSize);
end    