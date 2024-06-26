function h = histbw(x,edges,varargin)

labelspacing = 2;
linewidth = 1;
tickfraction = 100;
fontsize = 12;
axisoffsetfraction = 50;

datalinewidth = -1;
colororder = [1 1 1];
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
%clf(fig);
set(fig,'Color',[1 1 1]);
set(fig,'Clipping','off');

if ~isempty(colororder)
    set(gcf,'DefaultAxesColorOrder',colororder)
end

ax = gca;
cla(ax);
set(ax,'PlotBoxAspectRatio',[1 aspectratio 1]);

num_sets = size(x,2);
colors = get(gcf,'DefaultAxesColorOrder');

errorbarwidth = (edges(2)-edges(1))/10;

if num_sets==1
    y = histc(x,edges);  
    col = colors(1,:);
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
else
  disp(sprintf('I only work for one set at the moment!'));
    for ii = 1:num_sets
        y = histc(x(:,ii),edges);  
        col = colors(mod(ii-1,size(colors,1))+1,:);
        for jj = 1:length(y)-1
            p=patch([edges(jj) edges(jj+1) edges(jj+1) edges(jj)],[0 0 y(jj)/2 y(jj)/2],col);
            set(p,'FaceAlpha',.2,'EdgeColor',col);
        end
    end
end

% custom ticks and labels
axis off;

%xlim = get(ax,'XLim');
%ylim = get(ax,'YLim');

limits = [get(ax,'XLim') get(ax,'YLim')];
if ~isempty(axislimits)  
  limits(find(isfinite(axislimits))) = axislimits(find(isfinite(axislimits)));
end
xlim = limits(1:2);
ylim = limits(3:4);


if isempty(xaxisoffset)
  xaxisoffset = (ylim(2)-ylim(1))/axisoffsetfraction/aspectratio;
end

xaxline = line(xlim, [min(ylim)-xaxisoffset min(ylim)-xaxisoffset]);
set(xaxline,'Color','k');

if isempty(yaxisoffset)
  yaxisoffset = (xlim(2)-xlim(1))/axisoffsetfraction;
end
yaxline = line([min(xlim)-yaxisoffset min(xlim)-yaxisoffset],ylim);
set(yaxline,'Color','k');

xticksize = (ylim(2)-ylim(1))/tickfraction/aspectratio;
xtickpos = get(ax,'XTick');
xticklabels = get(ax,'XTickLabel');

xtickpos(find(xtickpos<(min(xlim)-1000*eps))) = nan;
xtickpos(find(xtickpos>(max(xlim)+1000*eps))) = nan;
f = find(isfinite(xtickpos));
xtickpos = xtickpos(f);
xticklabels = xticklabels(f,:);

xtick = line([xtickpos; xtickpos],repmat([min(ylim)-xaxisoffset;min(ylim)-xaxisoffset-xticksize],1,length(xtickpos)));
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
   xlabels(ii) = text(xtickpos(ii),min(ylim)-xaxisoffset-xticksize*labelspacing,txt);

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

ytick = line(repmat([min(xlim)-yaxisoffset; min(xlim)-yaxisoffset-yticksize],1,length(ytickpos)),[ytickpos; ytickpos]);
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
   ylabels(ii) = text(min(xlim)-yaxisoffset-yticksize*labelspacing,ytickpos(ii),txt);

   set(ylabels(ii),'VerticalAlignment',yvalign,'HorizontalAlignment',yhalign,'FontSize',fontsize,'Rotation',yticklabelangle);
end

if ~isempty(xlabeltext)
    xlabel = text((xlim(1)+xlim(2))/2,min(ylim)-xaxisoffset-xticksize*labelspacing*4,xlabeltext);
    set(xlabel,'VerticalAlignment','top','HorizontalAlignment','center','FontSize',fontsize);
end

if ~isempty(ylabeltext)
    ylabel = text(min(xlim)-yaxisoffset-yticksize*labelspacing*4,(ylim(1)+ylim(2))/2,ylabeltext);
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

% make sure printing is done in vector not bitmap format
set(fig,'Renderer','painters');

