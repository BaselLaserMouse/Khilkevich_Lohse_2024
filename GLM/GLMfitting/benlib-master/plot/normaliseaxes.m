function normaliseaxes(figurenum, mult)

if exist('figurenum','var')
  figure(figurenum);
end

if ~exist('mult', 'var')
  mult = [1 1 1 1];
end

children = get(gcf,'Children');

x = [+inf -inf];
y = [+inf -inf];
z = [+inf -inf];
c = [+inf -inf];

for ii = 1:length(children)
  if strcmp(get(children(ii),'Type'),'axes')
    xn = get(children(ii),'XLim');
    x = [min(xn(1),x(1)) max(xn(2),x(2))];
    yn = get(children(ii),'YLim');
    y = [min(yn(1),y(1)) max(yn(2),y(2))];
    zn = get(children(ii),'ZLim');
    z = [min(zn(1),z(1)) max(zn(2),z(2))];
    cn = get(children(ii),'CLim');
    c = [min(cn(1),c(1)) max(cn(2),c(2))];
  end
end

for ii = 1:length(children)
  if strcmp(get(children(ii),'Type'),'axes')
    set(children(ii),'XLim',x*mult(1));
    set(children(ii),'YLim',y*mult(2));
    set(children(ii),'ZLim',z*mult(3));
    set(children(ii),'CLim',c*mult(4));
  end
end
