function plotcsdkernelbyfreq(kernel)
% function plotcsdkernelbyfreq(kernel)
%
% Plot CSD kernel, freq by freq
%
% Inputs:
%  kernel.fhd -- kernel freq x history x depth
%  kernel.f -- freqs
%  kernel.h -- history times in ms

  n_freqs  = size(kernel.k_fhd, 1);
  m = 7;
  n = 5;

  kernel.k_fhd = kernel.k_fhd/max(abs(kernel.k_fhd(:)));

  plotsep = .2;
  for freqidx = 1:n_freqs
    subplotbw(m, n, freqidx, plotsep);
    k = squeeze(kernel.k_fhd(freqidx,:,:))';
    imagesc(kernel.h, 1:size(kernel.k_fhd,3), fliplr(k), [-1 1]);
    xtick = get(gca, 'xtick');
    ytick = get(gca, 'ytick');
    set(gca, 'xtick', [], 'ytick', []);

    if freqidx==1 || freqidx==n || freqidx==n_freqs
      t = title(sprintf('%0.0f Hz', kernel.f(freqidx)));
      pos = get(t, 'position');
      set(t, 'position', pos+[0 1 0]);
    end
  end

  colormap(colormap_redblackblue);
  subplotbw(m,n,(m-1)*n+1, plotsep);
  set(gca, 'xtick', xtick, 'ytick', ytick);

  x = xlabel('History (ms)');
  pos = get(x, 'position');
  set(x, 'position', pos+[0 0.001 0]);
  ylabel('Depth');