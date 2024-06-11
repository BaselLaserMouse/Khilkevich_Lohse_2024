function flt = makeCompensationFilter(sampleRate, ...
  ft, cutoffLo, cutoffHi, newSampleRate, newLength)
% flt = makeCompensationFilter(sampleRate
%       frequencyResponse, cutoffLo, cutoffHi, newSampleRate)
%
% Given an FFT, create an inverse filter to compensate for it
%
% 
% cutoffLo, cutoffHi: frequencies beyond which we will not attempt to flatten
% newSampleRate: new sample rate, if desired
%
% FFT structure is [0 lo....hi  fs/2  hi....lo]
%   in indices     [1 2....l/2 l/2+1 l/2+2..end]

% get just the frequency response, i.e. the absolute values of the
% first sz/2+1 coefficients
frLen = length(ft)/2 + 1;
freqs = linspace(0, sampleRate/2, frLen);
fr = abs(ft(1:frLen));

% inverse filter
fr = 1 ./ fr;

% flatten above cutoffHi
idx = find(freqs>cutoffHi, 1);
fr(idx:end) = fr(idx-1);

% flatten below cutoffLo (inc DC)
idx = find(freqs<cutoffLo, 1, 'last');
fr(1:idx-1) = fr(idx);

% change sample rate
if exist('newSampleRate', 'var')
  if newSampleRate>sampleRate
    error('don''t know how to upsample');
  elseif newSampleRate<sampleRate
    % take the elements of the frequency response that correspond
    % to frequencies at and below the new sample rate.
    newLen = find(freqs==newSampleRate/2);
    if isempty(newLen)
      error('can''t resample precisely between these frequencies');
    end
    freqs = freqs(1:newLen);
    fr = fr(1:newLen);
  end
end

% recreate full FFT (amplitude only, not phase)
ft = [fr fr(end-1:-1:2)];

% construct filter
s=length(ft)/2; % a slope s on the phases centers the fir filter
flt = real(ifft( ft .* exp(j*(-s*pi:pi:(s-1)*pi))));   

% reduce the length of the filter, if desired
% keeping it centred on the centre
if exist('newLength', 'var')
  if newLength>length(flt)
    error('making the filter longer is silly')
  else
    ctr = length(flt)/2 + 1;
    flt = flt(ctr-newLength/2:ctr+newLength/2-1);
    flt = flt - mean(flt);
  end
end
