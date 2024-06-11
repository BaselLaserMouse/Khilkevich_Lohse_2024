function k = warpkernel(k_fh, h, dt, t_max)
% function k = warpkernel(k_fh, h, dt)
%
% "Warp" a non-uniformly spaced kernel back into linear time
% 
% Useful for kernels estimated with getstimulushistory
% (which produces non-unformly spaced stimulus history)
% 
% Inputs:
%  k_fh -- kernel, n_f x n_h in size
%  h    -- the times at which the kernel is estimated
%  dt   -- the desired linear time resolution

if ~exist('t_max', 'var')
	t_max = max(h);
end

[n_f, n_h] = size(k_fh);
h_max = ceil(t_max/dt)*dt;
k = nan(n_f, h_max/dt);

d = round(diff(h)/dt);
for bb = 1:length(d)
	startIdx = h(bb)/dt+1;
	reps = d(bb);
	k(:,startIdx:startIdx+reps-1) = repmat(k_fh(:,end+1-bb), [1 reps]);
end
k = fliplr(k);
