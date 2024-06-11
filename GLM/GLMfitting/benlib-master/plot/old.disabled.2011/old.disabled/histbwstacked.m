function h = histbwstacked(x,edges,varargin)

labelspacing = 2;
linewidth = 1;
tickfraction = 100;
fontsize = 12;
axisoffsetfraction = 50;

datalinewidth = -1;
colororder = [.8 .8 .8; 0.8 0 0; 0 0.8 0; 0 0 0.8; 0.8 0.8 0];
xlabeltext = [];
ylabeltext = [];
xticklabelangle = 0;
yticklabelangle = 90;
aspectratio = 1;
fixzero_x = 0;
fixzero_y = 0;
legendtext = [];
found = 1;
errorbarmin = [];
errorbarmax = [];
axislimits = [];
xaxisoffset = [];
yaxisoffset = [];
showzerobars = 1;

while length(varargin)>=2 && found
    if strfind(varargin{end-1},'DataLineWidth')
        datalinewidth = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'ColorOrder')
        colororder = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'XLabel')
        xlabeltext = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'YLabel')
        ylabeltext = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'XTickLabelAngle')
        xticklabelangle = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'YTickLabelAngle')
        yticklabelangle = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'AspectRatio')
        aspectratio = varargin{end}*.9; % !! 0.9 gives square plots! I 
                                        % don't know why! Of course, this hack
                                        % means that other proportions are
                                        % wrong, but they are anyway, and
                                        % you usually do those by eye
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'FixZeroX')
        fixzero_x = varargin{end};
        varargin = varargin(1:end-2);
        
    elseif strfind(varargin{end-1},'FixZeroY')
        fixzero_y = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'Legend')
      
        legendtext = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'ErrorBarMin');
        errorbarmin = varargin{end};
        varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'ErrorBarMax');
        errorbarmax = varargin{end};
        varargin = varargin(1:end-2);  
    elseif strfind(varargin{end-1},'AxisLimits');
      axislimits = varargin{end};
      varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'XAxisOffset');
      xaxisoffset = varargin{end};
      varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'YAxisOffset');
      yaxisoffset = varargin{end};
      varargin = varargin(1:end-2);
    elseif strfind(varargin{end-1},'ShowZeroBars');
      showzerobars = varargin{end};
      varargin = varargin(1:end-2);
    else
        found = 0;
    end
end

fig = gcf;
set(fig,'Color',[1 1 1]);
set(fig,'Clipping','off');

if ~isempty(colororder)
    set(gcf,'DefaultAxesColorOrder',colororder)
end

ax = gca;
cla(ax);
%set(ax,'PlotBoxAspectRatio',[1 aspectratio 1]);

all_x = x;
num_sets = length(all_x);
colors = get(gcf,'DefaultAxesColorOrder');

errorbarwidth = (edges(2)-edges(1))/10;

for setnum = 1:num_sets
  x = all_x{setnum};
  y = histc(x,edges);
  col = colors(setnum,:);
  for jj = 1:length(y)-1
    p=patch([edges(jj) edges(jj+1) edges(jj+1) edges(jj)],[0 0 y(jj) y(jj)],col);
  if y(jj)~=0 || showzerobars == 1
    set(p,'FaceColor',col,'EdgeAlpha',1,'FaceAlpha',0.2);
  else
    set(p,'FaceColor',[1 1 1],'EdgeColor',[1 1 1],'EdgeAlpha',1,'FaceAlpha',0.2);
  end
  if ~isempty(errorbarmin)
    x_tmp = mean(edges(jj),edges(jj+1));
    l=line([x_tmp x_tmp],[y(jj) errorbarmin(jj)]);
    l=line([x_tmp-errorbarwidth x_tmp+errorbarwidth],[errorbarmin(jj) errorbarmin(jj)]);
  end
  if ~isempty(errorbarmax)
    x_tmp = mean(edges(jj),edges(jj+1));
    l=line([x_tmp x_tmp],[y(jj) errorbarmax(jj)]);
    l=line([x_tmp-errorbarwidth x_tmp+errorbarwidth],[errorbarmax(jj) errorbarmax(jj)]);
  end
end
end

x = all_x{:};
y = histc(x,edges);

[xmn xstep xmx] = chooseticks(edges,8);
xmn = min(edges);
xmx = max(edges);
xlim = [xmn xmx];

[ymn ystep ymx] = chooseticks(y,5);
ylim = [ymn ymx];

set(ax,'PlotBoxAspectRatio',[1 aspectratio 1]);
%set(ax,'DataAspectRatio',[(xmx-xmn) (ymx-ymn) 1]);
set(ax,'XLim',[xmn xmx]);
set(ax,'YLim',[ymn ymx]);
set(ax,'XTick',xmn:xstep:xmx);
set(ax,'YTick',ymn:ystep:ymx);
set(ax,'TickDir','out');
set(gca,'Box','off');
set(gca,'FontSize',12);

% custom ticks and labels
set(ax,'Color',[1 1 1]);
set(ax,'Clipping','off');


if ~isempty(legendtext)
    legend(legendtext);
end

% from exportfig.m
allLines  = findall(fig, 'type', 'line');
allText   = findall(fig, 'type', 'text');
allAxes   = findall(fig, 'type', 'axes');
allImages = findall(fig, 'type', 'image');
allLights = findall(fig, 'type', 'ligfigt');
allPatch  = findall(fig, 'type', 'patch');
allSurf   = findall(fig, 'type', 'surface');
%allRect   = findall(fig, 'type', 'rectangle');
%allFont   = [allText; allAxes];
%allColor  = [allLines; allText; allAxes; allLights];
allMarker = [allLines; allPatch; allSurf];
%allEdge   = [allPatch; allSurf];
%allCData  = [allImages; allPatch; allSurf];

set(allMarker,'LineWidth',linewidth);

% make sure printing is done in vector not bitmap format
set(fig,'Renderer','painters');

