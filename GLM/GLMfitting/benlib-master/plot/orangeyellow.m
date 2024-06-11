function col = orangeyellow(nsteps, step)

if ~exist('step', 'var') || isinteger(step)
	step = 1:nsteps;
end

orange  = [255 80 0]/255;
yellow  = [1 1 0];

proportion = ((step-1)./(nsteps-1))';
col = (1-proportion)*orange + proportion*yellow;
