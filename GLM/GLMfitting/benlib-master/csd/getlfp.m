function lfp = getlfp(signal, fs)
% function lfp = getlfp(signal, fs)
%
% Calculate LFP from raw voltage record
% 
% Inputs:
%  signal -- the raw voltage trace
%  fs -- sampling rate of signal
% 
% Outputs:
%  lfp -- the resulting LFP
  
  global chebyHd

  if floor(fs-24414)~=0
    error('Expecting sample rate of 24414Hz');
  end

  if isempty(chebyHd)
    [z,p,k] = cheby1(8,0.05,300/(fs/8/2));
    [sos,g] = zp2sos(z,p,k);
    chebyHd = dfilt.df2tsos(sos,g);
  end
  
  % we will use a two step downsampling: first decimate by a factor of 8
  % then go down to 1000 Hz sample rate
  
  t = T(signal, fs);
  t_max = max(t);
  
  % decimate by a factor of 8
  signal = decimate(signal, 8);
  nbeg = 8 - (8*ceil(L(t)/8) - L(t));
  t = t(nbeg:8:L(t));

  % low pass filter
  signal = filtfilthd(chebyHd,signal);

  % interpolate to get 1kHz sample freq
  t_1k = (1:round(max(t_max)*1000))/1000;
  lfp = interp1(t,signal,t_1k,[],'extrap')';
