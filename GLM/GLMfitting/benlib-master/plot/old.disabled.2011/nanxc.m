function xc = nanxc(x,y)

notnan = find(isfinite(x) & isfinite(y));
xcmat = corrcoef(x(notnan),y(notnan));

if size(xcmat,1)>1
  xc = xcmat(1,2);
else
  xc = nan;
end
