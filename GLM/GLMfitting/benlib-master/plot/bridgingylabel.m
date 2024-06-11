function [axisHandle,textHandle] = bridgingylabel(varargin)
% add a label centred to the left of all subplots
% NB If you have an odd number of plots, just label
% the middle plot; you don't need this function

fig = gcf;

txt = varargin{1};

if nargin==1
    dist = 1;
else
    dist = varargin{2};
end


children = get(fig,'children');

pos = {};
for ii = 1:length(children);
  if strcmp(get(children(ii), 'type'), 'axes')
	  [x y w h] = itemise(get(children(ii),'position'));
  	pos{end+1} = [x y x+w y+h];
  end
end
pos = cell2mat(pos');

[xmin ymin xmax ymax] = itemise([min(pos(:,1)) min(pos(:,2)) max(pos(:,3)) max(pos(:,4))]);
rect = [xmin ymin xmax-xmin ymax-ymin];
axisHandle = axes('position',rect);
xlim([0 1]);
ylim([0 1]);
 
% Add text. You can't use ylabel because, when
% you print, the label is changed to the color in 'ycolor' (which is white here)
textHandle = text(-.07*dist,.5,txt,'rotation',90,'verticalalignment','middle','horizontalalignment','center');

% Make most of the plot white. You can't use tranparency because it changes the
% renderer mode, which results in pixellated raster format images(!)
axis off;
set(axisHandle,'xcolor',[1 1 1],'ycolor',[1 1 1]);

% Send the plot to the bottom so it doesn't obscure the real plots
uistack(axisHandle,'bottom');

% Finally, this is required to get rid of axis lines at the bottom of each plot (why?)
%set(gcf,'color',[1 1 1]);
