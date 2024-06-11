function vasStim = applyVAS(stim, flt, itd)
% function vasStim = applyVAS(stim, flt, itd)
% apply VAS to a stimulus
% 
% stim is nx1
% flt.L and flt.R are a pair of minimum phase filters
% as produced by getVASfilter
% itd is the desired ITD

% convolve
vasStim.L = conv(stim, flt.L);
vasStim.R = conv(stim, flt.R);

z = zeros(abs(itd),1);

% a positive ITD means the left channel leads
if itd>0
  vasStim.L = [vasStim.L; z];
  vasStim.R = [z; vasStim.R];
else
  vasStim.L = [z; vasStim.L];
  vasStim.R = [vasStim.R; z];
end