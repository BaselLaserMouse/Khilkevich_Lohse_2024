function f = circle( ctr, rad, opts )
% CIRCLE draws a circle
%	
%	circle( ctr, rad, opts )
%
%	circle( ctr, rad ) defaults opts to '-'
%
%	Matteo 1995

if ~exist('opts', 'var')
  opts = '-';
end

theta = linspace(-pi,pi);
f=plot(ctr(1)+rad*cos(theta), ctr(2)+rad*sin(theta), opts);
