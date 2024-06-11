function y = plotbw(varargin)
% function y = plotbw(varargin)
%
% Produce publication-quality? 2D plots.  Syntax is as plot.m, but
% there are various options you can add on the end in key-value pairs
%
% Improvements over plot.m
% * Sensible line thickness (for a quarter-screen window)
% * Square aspect ratio (or set using 'AspectRatio',foo)
% * Ticks and labels in sensible size font
% * Set labels using ('XLabel',{'First line';'second line'},'YLabel',bar)
% * Set axes to include zero with ('FixZeroX',1,'FixZeroY',1)
% * Legend in matching font ('Legend',{'foo';'bar'})
% * Set data line width (this will override any setting in the plot cmd)
%     using ('DataLineWidth',foo)
% * Set order of colors for data lines ('ColorOrder',[0 0 0; .5 .5 .5...])
% * Oriented tick labels ('XTickLabelAngle',foo,'YTickLabelAngle',bar)
%
% bw may 2007

labelspacing = 2;
linewidth = 1;
tickfraction = 100;
fontsize = 12;

datalinewidth = -1;
colororder = [];
xlabeltext = [];
ylabeltext = [];
xticklabelangle = 0;
yticklabelangle = 90;
aspectratio = 0.4;
fixzero_x = 0;
fixzero_y = 0;
legendtext = [];
axislimits = [];
found = 1;

while length(varargin)>3 && found
    if isnumeric(varargin{end-1})
      found = 0;
    elseif strfind(varargin{end-1},'DataLineWidth')
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
    elseif strfind(varargin{end-1},'AxisLimits');
      axislimits = varargin{end};
      varargin = varargin(1:end-2);
    else
        found = 0;
    end
end

fig = gcf;
%clf(fig);
set(fig,'Color',[1 1 1]);
set(fig,'Clipping','off');

if ~isempty(colororder)
    set(gcf,'DefaultAxesColorOrder',colororder)
end

ax = gca;

series = plot(varargin{:});

% fix axes to go to zero if necessary.  A hack because using axis() turns
% on clipping outside the axes which means my custom ticks don't show up

xlim = get(ax,'XLim');
ylim = get(ax,'YLim');

extrapointpos = [xlim ylim];

if ~isempty(axislimits)
  f = find(isfinite(axislimits));
  extrapointpos(f) = axislimits(f);
end
  
if (fixzero_x==1)
    extrapointpos(1) = 0;
    extrapointpos(2) = 0;
end
if (fixzero_y==1)
    extrapointpos(3) = 0;
    extrapointpos(4) = 0;
end

extrapoint = line([extrapointpos(1) extrapointpos(1)],[extrapointpos(3) extrapointpos(3)]);
set(extrapoint,'Color',[1 1 1]);
extrapoint = line([extrapointpos(2) extrapointpos(2)],[extrapointpos(4) extrapointpos(4)]);
set(extrapoint,'Color',[1 1 1]);

set(ax,'PlotBoxAspectRatio',[1 aspectratio 1]);
set(ax,'FontSize',fontsize);
set(ax,'Clipping','off');

% better sizes for some markers -- e.g. default + looks too small compared to o 
for ii = 1:length(series)
  marker=get(series(ii),'Marker');
  markersz=get(series(ii),'MarkerSize');
  if marker=='+'
      set(series(ii),'MarkerSize',markersz*1.5);
  elseif marker=='.'
      set(series(ii),'MarkerSize',markersz*2);
  end
end

% custom ticks and labels
axis off;

xlim = get(ax,'XLim');
ylim = get(ax,'YLim');
axlines = line([xlim; xlim; min(xlim) min(xlim); max(xlim) max(xlim)], [min(ylim) min(ylim); max(ylim) max(ylim); ylim; ylim]);
set(axlines,'Color','k');

xticksize = (ylim(2)-ylim(1))/tickfraction/aspectratio;
xtickpos = get(ax,'XTick');
xticklabels = get(ax,'XTickLabel');

xtickpos(find(xtickpos<(min(xlim)-1000*eps))) = nan;
xtickpos(find(xtickpos>(max(xlim)+1000*eps))) = nan;
f = find(isfinite(xtickpos));
xtickpos = xtickpos(f);
xticklabels = xticklabels(f,:);

xtick = line([xtickpos; xtickpos],repmat([min(ylim);min(ylim)-xticksize],1,length(xtickpos)));
set(xtick,'Color','k');

if xticklabelangle==0
    xvalign='top';xhalign='center';
else
    xvalign='top';xhalign='right';
end

xlabels = [];
for ii = 1:size(xticklabels,1)
   txt = xticklabels(ii,:);
   while txt(end)==' '
       txt = txt(1:end-1);
   end
   xlabels(ii) = text(xtickpos(ii),min(ylim)-xticksize*labelspacing,txt);

   set(xlabels(ii),'VerticalAlignment',xvalign,'HorizontalAlignment',xhalign,'FontSize',fontsize,'Rotation',xticklabelangle);
end

yticksize = (xlim(2)-xlim(1))/tickfraction;
ytickpos = get(ax,'YTick');
yticklabels = get(ax,'YTickLabel');

ytickpos(find(ytickpos<(min(ylim)-1000*eps))) = nan;
ytickpos(find(ytickpos>(max(ylim)+1000*eps))) = nan;
f = find(isfinite(ytickpos));
ytickpos = ytickpos(f);
yticklabels = yticklabels(f,:);

ytick = line(repmat([min(xlim); min(xlim)-yticksize],1,length(ytickpos)),[ytickpos; ytickpos]);
set(ytick,'Color','k');

if yticklabelangle==90
    yvalign='bottom';yhalign='center';
else
    yvalign='middle';yhalign='right';
end

ylabels = [];
for ii = 1:size(yticklabels,1)
   txt = yticklabels(ii,:);
   while txt(end)==' '
       txt = txt(1:end-1);
   end
   ylabels(ii) = text(min(xlim)-yticksize*labelspacing,ytickpos(ii),txt);

   set(ylabels(ii),'VerticalAlignment',yvalign,'HorizontalAlignment',yhalign,'FontSize',fontsize,'Rotation',yticklabelangle);
end

if ~isempty(xlabeltext)
    xlabel = text((xlim(1)+xlim(2))/2,min(ylim)-xticksize*labelspacing*4,xlabeltext);
    set(xlabel,'VerticalAlignment','top','HorizontalAlignment','center','FontSize',fontsize);
end

if ~isempty(ylabeltext)
    ylabel = text(min(xlim)-yticksize*labelspacing*4,(ylim(1)+ylim(2))/2,ylabeltext);
    set(ylabel,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',fontsize,'Rotation',90.0);
end

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

% thicker lines for data points than axes?
if (datalinewidth ~= -1)
    for ii = 1:length(series)
        set(series(ii),'LineWidth',datalinewidth);
    end
end