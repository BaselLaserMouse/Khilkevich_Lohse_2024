function w_image = whitentocutoff(image, f0)
% cutoff in cycles per image

ft_image = fft2(image);
ft_abs   = abs(ft_image);

% make the image perfectly white
ft_wimage = ft_image./ft_abs;

% now put in the cut-off
sz = size(ft_image);

[Y, X] = ndgrid(-sz(1)/2+1:sz(1)/2,-sz(2)/2+1:sz(2)/2);

if (max(Y(:)))<max(X(:))
  Y = Y/max(Y(:))*max(X(:));
end

if (max(X(:)))<max(Y(:))
  X = X/max(X(:))*max(Y(:));
end

Y = abs(Y)<f0;
X = abs(X)<f0;
F = Y&X;

wid = ceil(f0/10);
Gs= makemgauss(wid*8,wid*4+1,wid*4+1,wid);
G = zeros(size(F));
G(size(F,1)/2-wid*4+1:size(F,1)/2+wid*4, ...
   size(F,2)/2-wid*4+1:size(F,2)/2+wid*4) = ...
   Gs;
S = fftshift(real(ifft2(fft2(F).*fft2(G))));

%S = conv2(F,makemgauss(wid*4,wid*2+1,wid*2+1,wid),'same');

ft_wimage = ft_wimage.*fftshift(S);

w_image = real(ifft2(ft_wimage));
