function ax = histbwnew(data,edges,varargin)

params = struct();

params.ColorOrder = [.2 .2 .2; .8 .8 .8; 1 1 1; 0 0 0];

for ii = 1:2:length(varargin)
  params = setfield(params,varargin{ii},varargin{ii+1});
end

if iscell(data)
  y = zeros(length(edges),length(data));
  for ii = 1:length(data)
    y(:,ii) = histc(data{ii},edges);
  end
  allbars = bar(edges,y,2,'grouped');
else
  y = histc(data,edges);
  allbars = bar(edges,y,'histc');
end

ax = gca;
set(ax,'Box','off');
set(ax,'TickDir','out');
pbaspect([1 0.5 1]);
for ii = 1:length(allbars)
  thisbar = allbars(ii);
  params.ColorOrder(ii,:)
  set(thisbar,'FaceColor',params.ColorOrder(ii,:));
end

% from exportfig.m
fig = gcf;
linewidth = 1;
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

