function H = ctest(l1,n1,l2,n2)

p = (n1/n2)*(l1/l2) / (1 + (n1/n2)*(l1/l2));

s = 0;
for i = k1:k
  s = s + nchoosek(k,i) * p^i * (1-p)^i;
end
