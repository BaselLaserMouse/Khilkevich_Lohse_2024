function x = samtone(f_c, f_m, A, m, ph_c, ph_m, t)
% function x = samtone(f_c, f_m, A, m, ph_c, ph_m, t)
% 
% f_c: carrier frequency
% f_m: modulation frequency
% A: overall amplitude
% m: modulation depth
% ph_c: phase of carrier
% ph_m: phase of modulation
% t: times at which to evaluate
% BW May 2008

x = A/2 * sin(2*pi*f_c*t-ph_c) .* (1 + m * sin(2*pi*f_m*t-ph_m));
