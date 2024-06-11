function s = vinjesparseness(r)
% calculate vinje sparseness

r = r(:);
r = r(find(isfinite(r)));

if isempty(r) || max(abs(r))==0
  s = nan;
  return;
end

n = length(r);

s1 = (sum(r)/n)^2;
s2 = sum((r.^2/n));

s = 1-(s1/s2);

s = s/(1-(1/n));
