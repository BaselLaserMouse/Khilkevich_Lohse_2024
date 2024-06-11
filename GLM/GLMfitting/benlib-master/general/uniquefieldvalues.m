function t = uniquefieldvalues(s)
%function t = uniquefieldvalues(s)
% returns all unique values of the fields in structure s

t = structarrayfun(@(x) unique(x),s);