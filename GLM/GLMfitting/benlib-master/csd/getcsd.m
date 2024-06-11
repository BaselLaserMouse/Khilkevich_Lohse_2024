function csd_matrix = compute_csd(lfp_matrix, chanstokeep, site_spacing, showresults, time_range)
% function csd_matrix = compute_csd(lfp_matrix, chanstokeep, site_spacing, showresults, time_range)
%
% Compute CSD from LFP data matrix
%
% Inputs:
%  lfp_matrix -- matrix of LFP data (shape?? see compute_lfp_from_f32s)
%  chanstokeep -- vector of channel numbers to include ('good channels')
%  site_spacing -- spacing of probe sites in um
%  show_results -- ?
%  time_range -- ?
%
% Outputs:
%  csd_matrix -- matrix of CSD data

tokeep = struct;
if exist('chanstokeep', 'var')
  tokeep.all = chanstokeep;
else
  tokeep.all = 1:size(lfp_matrix,1);
end

if ~exist('time_range', 'var')
  time_range = [0,100];
end

% extract metadata
n.channels = L(tokeep.all);
n.time = size(lfp_matrix, 2);
n.repeats = size(lfp_matrix, 3);


%% compute csd for all repeats
% =============================

csd_matrix = nan(n.channels, n.time, n.repeats);

% run through repeats
for rr = 1:size(lfp_matrix,3)
  lfpt = lfp_matrix(:,:,rr);
  lfpt = subtract_mean(lfpt);

  % calculate csd
  params = struct;
  params.site_spacing = site_spacing;
  params.CSD_type = 'delta';
  params.tokeep = tokeep.all;
  csdt = compute_csd(lfpt, params);
  csd_matrix(:,:,rr) = csdt;
  
end
  
if exist('showresults', 'var') && showresults
  %% show what we've done
  % ========================

  % colour axis to use
  csdt = mean(csd_matrix, 3);
  maxval = maxall(csdt);
  cax = maxval * [-1 1];

  % show: whole csd trace
  clf;
  subplot(2,1,1);
  imagesc(csdt);
  caxis(cax);
  title14bf('average CSD: whole trace');

  % show: centred on region:
  subplot(2,1,2);
  imagesc(csdt);
  xlim(time_range);
  caxis(cax);
  pan xon
  title14bf('average CSD: desired region');

  colormap(colormap_redblackblue);
end