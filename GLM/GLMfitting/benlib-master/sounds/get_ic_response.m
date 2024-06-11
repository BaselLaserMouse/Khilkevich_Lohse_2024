function ic_resp = get_ic_response(cochlea_frequencies, cochlea_binsize, cochleagram)
  % cochlea_frequencies: list of frequencies used in generating cochleagram (Hz)
  % cochlea_binsize: size of cochleagram time bins (seconds)
  % cochleagram: (n_frequencies by n_bins), as produced by cochleagram.m

  smoothingdur = 0.650; % seconds
  tauvalues = (500 + (395-500) * log10(cochlea_frequencies))/1000; % this is a linear regression in the log-space on the data of Dean et al. 2008, Fig. 5
  smoothed_cochleagram = nan(size(cochleagram,1),size(cochleagram,2)+(smoothingdur/cochlea_binsize)-1);
  for freq=1:size(cochleagram,1)
    binnedwindow = get_binned_window(['exp' num2str(tauvalues(freq))],smoothingdur,cochlea_binsize);
    binnedwindow = binnedwindow./sum(binnedwindow);
    smoothed_cochleagram(freq,:) = conv(cochleagram(freq,:),binnedwindow,'full');
  end
  smoothed_cochleagram(:,size(cochleagram,2)+1:end) = []; % remove convolution 'overshoot' at the end; this is not the same as conv(a,b,'same')!
  ic_resp = cochleagram - smoothed_cochleagram; % Subtract smooth version
  ic_resp(ic_resp<0) = 0; % Set all negative values to 0
