function subsets = getfitpredsets2(idx, n_subsets, seed)
% subsets = getfitpredsets2(idx, n_subsets, seed)
% 
% Choose multiple fit and prediction data indices for a data set. Will produce
% the same results every time, if given the same seed.
% The data is divided into n_subsets non-overlapping subsets. Each of these
% is used as the prediction set for one subset. All the rest of the data
% is used as the fit set.
%
% uses an input list of indices, rather than just n_t
% 
% Inputs:
%  idx -- indices to divide up (or a scalar n for 1:n)
%  n_subsets -- number of non-overlapping prediction sets to use
%  seed -- random number generator seed or nan for contiguous chunks

% randomly permute data
if exist('seed', 'var') && isfinite(seed)
	rand('seed', seed);
else
  seed = nan; % contiguous chunks
end

if length(idx)==1
	idx = 1:idx;
end

n_t = length(idx);

if isfinite(seed)
  idx = idx(randperm(n_t));
end

mean_n_per_subset = n_t/n_subsets;
boundaries = round([1:mean_n_per_subset:n_t n_t+1]);

subsets = {};
for subset_idx = 1:n_subsets
	subset = struct;
	pred_idx = boundaries(subset_idx):(boundaries(subset_idx+1)-1);
	fit_idx = setdiff(1:n_t, pred_idx);

	subset.fit_idx = sort(idx(fit_idx));
	subset.pred_idx = sort(idx(pred_idx));
	subsets{subset_idx} = subset;
end

subsets = [subsets{:}];

% check that for each subset, fit and prediction sets contain all the data and are non-overlapping
for subset_idx = 1:n_subsets
	fit_idx = subsets(subset_idx).fit_idx;
	pred_idx = subsets(subset_idx).pred_idx;

	all_idx = [fit_idx pred_idx];
	assert(length(all_idx)==n_t);
	assert(length(unique(all_idx))==n_t);
end

% check that all data is predicted once, and that all
% prediction sets are non-overlapping
all_pred = [subsets(:).pred_idx];
assert(length(all_pred)==n_t);
assert(length(unique(all_idx))==n_t);
