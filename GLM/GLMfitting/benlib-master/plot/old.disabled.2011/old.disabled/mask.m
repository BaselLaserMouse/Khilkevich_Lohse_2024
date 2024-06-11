%  function m=mask(length, ir, or)
% 
%   Returns a mask fit for using to alpha blend, given the three
% parameters that define an alpha mask: its size, inner radius, and
% outer radius.

function m=mask(length, ir, or)

if exist('or')==0
  or=floor(length/2);
end
if exist('ir')==0
  ir=0;
end


n=2*(1/length);
x=-1:n:1-n;
y=-1:n:1-n;    
[xx,yy]=meshgrid(x,y);
d=((xx.^2+yy.^2).^0.5);
d=1-d;
slope=1/(or-ir)*(length/2);
d=d.*slope;

y_intercept=(length/2-or)/(or-ir);
%y_intercept = 1;

d=d-y_intercept;
d=min(cat(3,ones(size(d)),d),[],3);
d=max(cat(3,zeros(size(d)),d),[],3);
m=d;
