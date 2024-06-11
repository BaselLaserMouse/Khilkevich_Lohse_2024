function plotsepcsdkernel(kernel)
% function plotsepcsdkernel(kernel)
%
% Plot separable CSD kernel
%
% Inputs:
%  kernel.k_f -- kernel freq x history x depth
%  kernel.k_hd -- kernel freq x history x depth
%  kernel.f -- freqs
%  kernel.h -- history times in ms

subplot(1,2,1);
mx = max(kernel.k_f);
plot(kernel.f, kernel.k_f/mx);
yl = ylim(gca);
ylim([yl(1) 1.1]);
set(gca, 'xtick', [min(kernel.f) max(kernel.f)]);
xlabel('Frequency, Hz');
ylabel('Normalised kernel');

subplot(1,2,2);
mx = max(abs(kernel.k_hd(:)));
imagesc(kernel.h, kernel.d, fliplr(kernel.k_hd')/mx, [-1 1]);
colormap(colormap_redblackblue);
colorbar;
xlabel('Time, ms');
ylabel('Depth')
drawnow;
