function [flt, itd] = getVASFilter(ov2, azimuth, elevation)
% [flt, itd] = getVASFilter(ov2, azimuth, elevation)
%
% this is a reimplementation of TVasParamsForm3.interpolatedFiltersFor
% which is to be found in VasDataDlgSys3.pas
%
% ov2: an ov2 structure (as produced by loadOVfile)
% azimuth, elevation: the desired sound location

% convert to single precision. This forces the whole distance calculation
% to be in single precision too (i.e. the variable dist). This is necessary
% to match interpolatedFiltersFor -- without it, rounding errors result in 
% different selections of nearest HRTF positions in cases where the distances
% are very similar
azimuth = single(azimuth);
elevation = single(elevation);

% convert to cartesian coordinates
[x, y, z] = sph2cart(deg2rad(azimuth), deg2rad(elevation), 1);
pos = [x y z];

[x, y, z] = sph2cart(deg2rad(ov2.azimuths), deg2rad(ov2.elevations), 1);
hrtfPos = [x y z];

% calculate distances between HRTF positions and desired position
dPos = hrtfPos - repmat(pos,size(hrtfPos,1),1);
dist = sqrt(sum(dPos.^2,2));

% sort distances in ascending order. idx contains the sorted indexes
% (i.e. idx(1) is the nearest, idx(2) is next...)
[sortedDist, idx] = sort(dist);

if sortedDist(1)==0
  % then we have an exact match, so just use that spectrum
  spectra = ov2.spectra(idx(1));
  itd = ov2.ITDs(idx(1));

else
  % no exact match, so make a weighted sum of three nearest spectra and ITDs
  nearestSpectra.L = [ov2.spectra(idx(1:3)).L];
  nearestSpectra.R = [ov2.spectra(idx(1:3)).R];
  nearestITDs = ov2.ITDs(idx(1:3));
  nearestDist = sortedDist(1:3);
  
  % proximity is 1 / distance
  proximity = 1./nearestDist;
  
  % weights are proximity / total proximity
  proximity = proximity / sum(proximity);
  
  % weighted sum of spectra
  proximityRep = repmat(proximity',size(nearestSpectra.L,1),1);
  spectra.L = sum(nearestSpectra.L.*proximityRep,2);
  spectra.R = sum(nearestSpectra.R.*proximityRep,2);
  
  % weighted sum of ITDs
  itd = round(sum(nearestITDs .* proximity));
  
end

% calculate minimum phase filters
flt.L = minPhase(spectra.L);
flt.R = minPhase(spectra.R);

% truncate filters
flt.L = flt.L(1:length(flt.L)/2);
flt.R = flt.R(1:length(flt.R)/2);
