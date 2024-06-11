function linkaxes(ax1,ax2)
%function linkaxes(ax1,ax2)
% Link two axes on the same plot, so they scale and otherwise change together.
% When you have two y-axes, one on the left and one on the right, you
% need this so they behave sensibly.
% The code comes from plotyy.m

ax = [ax1 ax2];
setappdata(ax(1),'graphicsPlotyyPeer',ax(2));
setappdata(ax(2),'graphicsPlotyyPeer',ax(1));
hLink = linkprop(ax,'View');
setappdata(ax(2),'graphicsPlotyyLinkProp',hLink);
hList(1) = handle.listener(handle(ax(1)),findprop(handle(ax(1)),'Position'),...
    'PropertyPostSet',{@localUpdatePosition,ax(1),ax(2)});
hList(2) = handle.listener(handle(ax(2)),findprop(handle(ax(2)),'Position'),...
    'PropertyPostSet',{@localUpdatePosition,ax(2),ax(1)});
setappdata(ax(1),'graphicsPlotyyPositionListener',hList);

% Keep the positions of two axes in sync:
function localUpdatePosition(obj,evd,axSource,axDest)
newPos = get(axSource,'Position');
hFig = ancestor(axSource,'Figure');
newDestPos = hgconvertunits(hFig,newPos,get(axSource,'Units'),get(axDest,'Units'),get(axSource,'Parent'));
set(axDest,'Position',newDestPos);