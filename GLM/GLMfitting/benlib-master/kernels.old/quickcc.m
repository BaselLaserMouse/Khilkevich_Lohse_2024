function r = quickcc(x1,x2)
  x = [x1 x2];
  [n,m] = size(x);
  	  x = bsxfun(@minus,x,sum(x,1)/n);  % Remove mean 
      r = (x' * x) / (n-1);  
  d = sqrt(diag(r)); % sqrt first to avoid under/overflow
  r = bsxfun(@rdivide,r,d); r = bsxfun(@rdivide,r,d'); % r = r ./ d*d';
  r = r(2);
end
