if 0
  
sz = 256;
ctr= sz/2+1;

l_carrier = 6;
l_envelope  = 80;

n_demod = 200;

H_demod = zeros(sz,sz,n_demod);
ctr_demod = zeros(2,n_demod);
for ii = 1:n_demod
  ii
  x = ceil(rand*sz);
  y = ceil(rand*sz);
  ctr_demod(:,ii) = [x y];
  H_demod(:,:,ii) = makeegabor(sz,x,y,l_carrier,1,0,0,l_carrier/2);
end

h_lum = makeegabor(sz,ctr,ctr,l_envelope,1,0,0,l_envelope/2);


carrier = makemgrat(sz,ctr,ctr,l_carrier,0,0);

l_stim_envelope = [10:5:160];
end

for ii = 1:length(l_stim_envelope)
  ii
  envelope = makemgrat(sz,ctr,ctr,l_stim_envelope(ii),0,0);
  stim_am = carrier.*envelope;
  stim_lum= envelope;

  r_lum(ii) = sum(sum(stim_lum.* h_lum));
  
  R1 = zeros(sz);
  for jj = 1:n_demod
    r1 = sum(sum(H_demod(:,:,jj).*stim_am));
    R1(ctr_demod(1,jj),ctr_demod(2,jj)) = abs(r1);
  end
  %keyboard;  
  r_am(ii) = sum(sum(R1 .* h_lum));
end

  