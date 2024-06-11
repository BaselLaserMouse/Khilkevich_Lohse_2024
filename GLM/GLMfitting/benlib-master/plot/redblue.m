function col = redblue(nsteps, step)

if ~exist('step', 'var') || isinteger(step)
	step = 1:nsteps;
end

red  = [1 0 0];
blue  = [0 0 1];

proportion = ((step-1)./(nsteps-1))';
col = (1-proportion)*red + proportion*blue;

if nsteps==1
  col = red;
end
