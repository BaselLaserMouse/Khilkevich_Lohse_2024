function saveOV2(filename, ov2)
% write an ov2 structure to disk in the format used by brainware

f=fopen(filename,'W');
fwrite(f, ov2.sampleRate, 'float32'); % need to halve this for 50K file
fwrite(f, ov2.nPositions,'int16'); % number of positions
fwrite(f, ov2.azimuths, 'int16'); % azimuths
fwrite(f, ov2.elevations, 'int16'); % elevations
fwrite(f, ov2.ITDs, 'int16'); % ITDs -- these are also halved for 50K file
fwrite(f, ov2.spectrumLength, 'int16'); % spectrum length
for ii = 1:length(ov2.spectra)
  fwrite(f, ov2.spectra(ii).L,'float32'); % spectrum chan1
  fwrite(f, ov2.spectra(ii).R,'float32'); % spectrum chan2
end; 
fclose(f);