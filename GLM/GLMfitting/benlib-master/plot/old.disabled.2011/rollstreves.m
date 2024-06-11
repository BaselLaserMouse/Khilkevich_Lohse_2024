function s = rollstreves(r)

top = (sum(r/length(r)))^2;
bottom = sum(r.^2/length(r));

s = top/bottom;
