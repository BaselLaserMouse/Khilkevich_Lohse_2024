% function H=vline(xloc,lineColor);
%
% This function draws vertical marker lines at [xloc] on the
% current axis. [lineColor] is as specify in plot.
%
% SEE ALSO: hline, dline, sline, vplane, vwall.
%
% By Michael Wu  --  waftingpetal@yahoo.com (Oct 2002)
%
% ====================

function H=vline(xloc,lineColor);

axH=gca;
curAx=axis(axH);
locSize=size(xloc);
locLen=prod(locSize);

vloc=reshape(xloc,1,locLen);
xCoord=repmat(vloc,2,1);

yLim=curAx([3,4])';
yCoord=repmat(yLim,1,locLen);

H=line(xCoord,yCoord);

if nargin>1
  if ~exist('lineColor','var');
    lineColor='b';
  end
    set(H,'color',lineColor);
end

