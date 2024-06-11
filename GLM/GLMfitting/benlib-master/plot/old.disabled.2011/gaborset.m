% to make the perfect gabor filter set:

% we want to space the gabors in space, SF and orientation at the
% same spacing. we do this by measuring the envelope in each
% dimension, and making sure the envelopes cross at approximately
% the same values.

% in space:
% gabor has a certain SD, sigma. the next gabor should be at a
% distance q * sigma from the first

% in SF:
% gabor has a bandwidth, determined by the relationship between the
% best SF of the gabor