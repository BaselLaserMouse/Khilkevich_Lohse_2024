function [mn step mx] = chooseticks(x, nsteps)
% calculate axis limits

if ~exist('nsteps','var')
  nsteps = 5;
end

mn = min(x)
mx = max(x)
step = (mx-mn)/nsteps;
magn = floor(log10(step));
step = step/(10^magn);
if step < 2 step = 2;
elseif step < 5 step = 5;
else step = 10;
end
step = step * 10^magn;
mn = floor(mn/step)*step;
mx = ceil(mx/step)*step;

