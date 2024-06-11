function z = unwrap2d(z)

sz  = size(z,1);
ctr = size(z,1)/2+1;

last = z(ctr,ctr);
for ring = 1:sz/2-1
  
  y = ctr-ring;
  for x = ctr-ring+1:ctr+ring-1
    z(y,x) = last+mod(z(y,x)-last,2*pi);
    last = z(y,x);
  end
  
  z(ctr-ring,ctr+ring) = ...
      last+mod(z(ctr-ring,ctr+ring)-last,2*pi);
  last = z(y,x);
  
  for y = ctr-ring+1:ctr+ring-1
    z(y,x) = last+mod(z(y,x)-last,2*pi);
    last = z(y,x);
  end
  
  z(ctr+ring,ctr+ring) = ...
      last+mod(z(ctr+ring,ctr+ring)-last,2*pi);
  last = z(y,x);
  
  for x = ctr+ring-1:-1:ctr-ring+1
    z(y,x) = last+mod(z(y,x)-last,2*pi);
    last = z(y,x);
  end
  
  z(ctr+ring,ctr-ring) = ...
      last+mod(z(ctr+ring,x)-last,2*pi);
  last = z(y,x);
  
  for y = ctr+ring-1:-1:ctr-ring
    z(y,x) = last+mod(z(y,x)-last,2*pi);
    last = z(y,x);
  end
  
end

[yy,xx] = ndgrid(1-ctr:sz-ctr,1-ctr:sz-ctr);
ff = sqrt(yy.^2+xx.^2);
ff(ctr,ctr) =1;
z = z./ff;