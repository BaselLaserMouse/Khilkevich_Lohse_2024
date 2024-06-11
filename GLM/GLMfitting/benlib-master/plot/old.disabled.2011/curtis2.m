sz = 256;
ctr= sz/2+1;

l_envelope  = 64;
l_carrier = l_envelope/8;

th_carrier = 0;
elong = 1;
h_demod_spread = .5;

pooling_exp = 2;

h_demod = makeegabor(sz,ctr,ctr,l_carrier,elong,0,th_carrier, ...
		     l_carrier.*h_demod_spread);
f_h_demod = fft2(fftshift(h_demod));

h_lum   = makeegabor(sz,ctr,ctr,l_envelope,1,0,0,l_envelope/2);
h_lum2  = makeegabor(sz,ctr,ctr,l_envelope,1,pi/2,0,l_envelope/2);

carrier = makemgrat(sz,ctr,ctr,l_carrier,0,th_carrier);

l_stim_envelope = linspace(1,l_envelope*3,50);

h_demod_mask = (rand(sz)>.99).*h_lum;

envelope = makemgrat(sz,ctr,ctr,l_envelope,0,0);
best_stim_am = (1+envelope) .* carrier;
subplot(2,4,1);
show(best_stim_am);
subplot(2,4,2);
show(h_demod);
subplot(2,4,3);
show(h_lum);
r_am = [];
r_lum = [];
for ii = 1:length(l_stim_envelope)
  ii

  envelope = makemgrat(sz,ctr,ctr,l_stim_envelope(ii),0,0);
  stim_am = (1+envelope) .* carrier;
  stim_lum = makemgrat(sz,ctr,ctr,l_stim_envelope(ii),0,0);

  r_lum(ii) = sum(sum(stim_lum.* h_lum)) + sum(sum(stim_lum.* h_lum2));
  
  f_stim_am = fft2(fftshift(stim_am));

  r1 = real(fftshift(ifft2(f_stim_am.*f_h_demod))).^pooling_exp;
  r1 = r1.*h_demod_mask;
  
  r_am(ii) = sum(sum(r1 .* h_lum)).^2 + sum(sum(r1 .* h_lum2)).^2;
  subplot(2,4,4);
  show(stim_am);
  subplot(2,1,2);
  plot(l_stim_envelope(1:ii),r_lum(1:ii)/max(r_lum(1:ii)), ...
       l_stim_envelope(1:ii),r_am(1:ii)/max(r_am(1:ii)),[l_envelope ...
		    l_envelope],[0 1]);
  drawnow;
end

fnd = find(r_am==max(r_am));

envelope = makemgrat(sz,ctr,ctr,l_stim_envelope(fnd(1)),0,0);
best_stim_am = (1+envelope) .* carrier;
subplot(2,4,4);
show(best_stim_am);