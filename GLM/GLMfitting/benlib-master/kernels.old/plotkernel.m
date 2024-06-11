function plotkernel(kernel)
% function plotkernel(kernel)
%
% Plot kernel
%
% Inputs:
%  kernel.fhd -- kernel freq x history x 1
%  kernel.f -- freqs
%  kernel.h -- history times in ms

  k = kernel.k_fhd(:,:,1);
  k = k/max(abs(k(:)));
  imagesc(kernel.h, kernel.f, fliplr(k), [-1 1])
  xtick = get(gca, 'xtick');
  ytick = get(gca, 'ytick');
  set(gca, 'xtick', [], 'ytick', []);

  colormap(flipud(colormap_redblackblue));
  set(gca, 'xtick', xtick, 'ytick', ytick);

  xlabel('History (ms)');
  ylabel('Frequency (Hz)');