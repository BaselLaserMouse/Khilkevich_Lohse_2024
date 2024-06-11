function col = bluered(nsteps, step)
% function col = bluered(nsteps, step)
%
% blue to red colours for plotting (not colourmap)

if ~exist('step', 'var') || isinteger(step)
	step = 1:nsteps;
end

blue = [0 0 1];
red  = [1 0 0];

proportion = ((step-1)./(nsteps-1))';
col = (1-proportion)*blue + proportion*red;
