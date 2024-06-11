function plotcsdkernelbydepth(kernel, scaleup)
% function plotcsdkernelbydepth(kernel)
%
% Plot CSD kernel, depth by depth
%
% Inputs:
%  kernel.fhd -- kernel freq x history x depth
%  kernel.f -- freqs
%  kernel.h -- history times in ms

if nargin<2
  scaleup = false;
end

n_depths  = size(kernel.k_fhd, 3);
if n_depths <= 16
  m = 4;
  n = 4;
else
  m = 6;
  n = 6;
end

if scaleup
  for ii = 1:size(kernel.k_fhd, 3)
    kernel.k_fhd(:,:,ii) = kernel.k_fhd(:,:,ii)/max(abs(ravel(kernel.k_fhd(:,:,ii))));
  end
else
  kernel.k_fhd = kernel.k_fhd/max(abs(kernel.k_fhd(:)));
end

plotsep = .2;

for depthidx = 1:n_depths
  subplotbw(m, n, depthidx, plotsep);
  k = kernel.k_fhd(:,:,depthidx);
  imagesc(kernel.h, kernel.f, fliplr(k), [-1 1])
  xtick = get(gca, 'xtick');
  ytick = get(gca, 'ytick');
  set(gca, 'xtick', [], 'ytick', []);
  if depthidx==1 || depthidx==n || depthidx==n_depths
    if depthidx==1
      t = title(['Depth = ' num2str(depthidx)]);
    else
      t = title(num2str(depthidx));
    end
  
    pos = get(t, 'position');
    set(t, 'position', pos+[0 1 0]);
  end  
end

colormap(colormap_redblackblue);
subplotbw(m,n,(m-1)*n+1, plotsep);
set(gca, 'xtick', xtick, 'ytick', ytick);

xlabel('History (ms)');
ylabel('Frequency (Hz)');