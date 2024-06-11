% function pal=redblue(n, expon);
%
% passed to colormap() function to set blue-->white-->red palette
%
% expon is the exponent of coloration. 
% (ie, 1= linear, <1 more white, >1 more color)
% 
function pal=redblue(n, expon);

if ~exist('n', 'var')
  n = 32;
end

if ~exist('expon','var'),
  expon=0.75;
end
skbottom=[linspace(0,1,n).^expon' linspace(0,1,n).^expon' ones(n,1)];
sktop=[ones(n,1) linspace(1,0,n).^expon' linspace(1,0,n).^expon'];
pal=[skbottom;sktop];
