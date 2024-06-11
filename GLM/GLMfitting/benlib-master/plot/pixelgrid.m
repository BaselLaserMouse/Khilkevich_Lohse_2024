function pixelgrid(col)

xl = xlim;
yl = ylim;

for ii = xl(1):1:xl(2);
  l = line( [ii ii], [yl(1) yl(2)]);
 set(l, 'color', col);  
  l = line( [xl(1) xl(2)], [ii ii]);
  set(l, 'color', col);
end
