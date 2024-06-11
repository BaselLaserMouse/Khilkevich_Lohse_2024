function dspec = addCovariateSpiketrain(dspec, covLabel, stimLabel, desc, basisStruct, varargin)
%
% Input
%   offset: [1] optional/default: 1 - number of **time bins** to shift the
%	regressors. Negative (positive) integers represent anti-causal (causal)
%	effects.

if nargin < 4 || isempty(desc); desc = covLabel; end

if nargin < 5
    %basisStruct = basisFactory.makeNonlinearRaisedCos(10, dspec.expt.binSize, [0 100], 1);
    
    %% this is new that im using long binning (50 ms)
    binfun = dspec.expt.binfun;
    basisStruct = basisFactory.makeSmoothTemporalBasis('boxcar', 1000, 1000/dspec.expt.binSize, binfun);
    %%

end

assert(ischar(desc), 'Description must be a string');

%offset = basisStruct.param.nlOffset; % Make sure to be causal. No instantaneous interaction allowed.
    
%% this is new that im using long binning (50 ms)
offset = 1; % Make sure to be causal. No instantaneous interaction allowed. --This is again changed for 50 ms binning
%%

assert(offset>0, 'Offset must be >0');

binfun = dspec.expt.binfun;
stimHandle = @(trial, expt) basisFactory.deltaStim(binfun(trial.(stimLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, basisStruct, offset, varargin{:});