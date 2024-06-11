function ov2 = makeOV2(az, el, DTF, ITD, compensationFilters)
% ov2 = makeOV2(az, el, DTF, ITD, compensationFilters)
% 
% Given a pair of compensation filters and HRTF information, generate
% an OV2 structure as used by applyVAS. This can be saved as an .ov2 file
% using saveOV2file
%
% The first few parameters come from a Schnupp HRTF recording:
%  az: vector of azimuths from HRTF data (from a rawHRTF.mat)
%  el: vector of elevations from HRTF data (from a rawHRTF.mat)
%  DTF: a DTF structure (load rawDTFs.mat; DTF.L = DTF1; DTF.R = DTF2; 
%       DTF.sampleRateHz = sample rate in Hz
%  ITD: a vector of ITds (from an ITDs.mat)
%
% The remaing one comes from headphone calibration:
% compensationFilters.L, .R: compensation filters
% compensationFilters.sampleRateHz: the sample rate
%
% The ov2 structure will be generated at the sample rate specified by the
% compensation filters, and the spectra will have the same length as the
% compensation filters
% 
% ov2 structure:
%  sampleRate: sample rate in Hz
%  nPositions: number of positions sampled
%  azimuths, elevations: vectors containing the positions
%  ITDs: ITDs in samples
%  spectra: the DTFs
%  spectrumLength: the length of the spectrum vectors

  ov2.sampleRate = compensationFilters.sampleRateHz;
  ov2.nPositions = size(DTF.L,1);
  ov2.azimuths = az;
  ov2.elevations = el;

  % scale to get the ITDs in samples at the new sample rate
  ov2.ITDs = round(ITD/DTF.sampleRateHz*compensationFilters.sampleRateHz)';

  % convert to normal coordinate system (see VasDataDlgSys3)
  if max(ov2.azimuths)>180
    ov2.azimuths = ov2.azimuths - 180;
    ov2.elevations = ov2.elevations - 90;
  end
  
  % convert the compensation filters back into frequency space and
  % take the abs to get amplitude spectra
  compensationSpectra.L = abs(fft(compensationFilters.L));
  compensationSpectra.R = abs(fft(compensationFilters.R));
  
  % the final spectra will be the same size as the compensation filters
  len = length(compensationSpectra.L);

  % DTFs are FFTs, so they have the frequencies
  % [0 lo..hi fs/2 hi..lo]
  DTFfreqs = linspace(0, DTF.sampleRateHz/2, size(DTF.L,2)/2+1);

  % take the part of the DTFs that correspond to DTFfreqs
  DTF.L = DTF.L(:,1:length(DTFfreqs));
  DTF.R = DTF.R(:,1:length(DTFfreqs));

  % work out the frequencies we need for the final frequency responses
  % we want [0 lo..hi new_fs/2]
  desiredFreqs = linspace(0, compensationFilters.sampleRateHz/2, len/2+1);

  ov2.spectrumLength = len;

  for ii = 1:size(DTF.L,1)
    % resample to get the spectra at the new sample rate
    tempDTF = interp1(DTFfreqs, DTF.L(ii,:), desiredFreqs);
    
    % flip the lo...hi part of the spectrum and add it on the end, leaving
    ov2.spectra(ii).L = [tempDTF tempDTF(end-1:-1:2)] .* compensationSpectra.L;

    % resample to get the spectra at the new sample rate
    tempDTF = interp1(DTFfreqs, DTF.R(ii,:), desiredFreqs);

    % flip the lo...hi part of the spectrum and add it on the end, leaving
    ov2.spectra(ii).R = [tempDTF tempDTF(end-1:-1:2)] .* compensationSpectra.R;
  end

