function im=quickalpha(im,bg,r1,r2)

%%%% quickalpha.m
% Does an alpha blend of im and bg between radii r1 and r2
% BW 11-20-02

for ii = 1:size(im,3)

  pl = im(:,:,ii);
  sz = size(pl);
  y_ctr=sz(1)/2+1;
  x_ctr=sz(2)/2+1;
  
  [x,y]=meshgrid(-x_ctr+1:x_ctr-2,-y_ctr+1:y_ctr-2);
  
  mask = sqrt(x.^2+y.^2);
  mask = mask-r1;
  mask = max(mask,0);
  mask = mask./(r2-r1);
  mask = min(mask,1);

  im(:,:,ii) = mask.*bg + (1-mask).*pl;
  
end


