function ov2 = loadOV2file(filename)
% function ov2 = loadOV2file(filename)
%
% load an Oxford VAS 2 (ov2) file into a matlab structure

f=fopen(filename,'r');
ov2.sampleRate = fread(f, 1, 'float32'); % sample rate
ov2.nPositions = fread(f, 1, 'int16'); % number of positions
ov2.azimuths = fread(f, ov2.nPositions, 'int16');
ov2.elevations = fread(f, ov2.nPositions, 'int16');

% convert to normal coordinate system (see VasDataDlgSys3)
if max(ov2.azimuths)>180
  ov2.azimuths = ov2.azimuths - 180;
  ov2.elevations = ov2.elevations - 90;
end

ov2.ITDs = fread(f, ov2.nPositions, 'int16');
ov2.spectrumLength = fread(f, 1, 'int16');
ov2.spectra = struct();
for ii = 1:ov2.nPositions
  ov2.spectra(ii).L = fread(f, ov2.spectrumLength, 'float32');
  ov2.spectra(ii).R = fread(f, ov2.spectrumLength, 'float32');
end

% check that we've reached the end of the file
dummy = fread(f, 1, 'float32');
if ~isempty(dummy) || ~feof(f)
  fclose(f);
  error('problem reading ov2 file');
end

fclose(f);