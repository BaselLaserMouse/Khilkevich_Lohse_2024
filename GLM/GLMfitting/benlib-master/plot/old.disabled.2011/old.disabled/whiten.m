function w_image = whiten(image, f0)

ft_image = fft2(image);
ft_abs   = abs(ft_image);
ft_image = ft_image./ft_abs;

sz = size(ft_image);

[Y, X] = ndgrid(-sz(1)/2+1:sz(1)/2,-sz(2)/2+1:sz(2)/2);
Y = fftshift(Y);
X = fftshift(X);

if (max(Y(:)))<max(X(:))
  Y = Y/max(Y(:))*max(X(:));
end

if (max(X(:)))<max(Y(:))
  X = X/max(X(:))*max(Y(:));
end

F = sqrt(X.^2+Y.^2);
r = F <  1/2*max(max(Y(:)),max(X(:)));

w_image = abs(ifft2(ft_image.*r));
keyboard;

