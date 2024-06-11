function sig = ttestwrapper(x1,x2, ntails)

if ~exist('ntails','var')
  ntails = 2;
end

if ntails == 1
  if mean(x1)<mean(x2)
    tail = 'left';
  else
    tail = 'right';
  end
else
  tail = 'both';
end

fprintf(['T test: mean(x1) = ' num2str(mean(x1),4) '; mean(x2) = ' num2str(mean(x2),4) '\n']);

sig = 0;
ps = [0.01 0.05 0.1];
for p=ps
  if ttest2(x1,x2,p,tail)
    fprintf(['Significant at P=' num2str(p) ' (' num2str(ntails) '-tailed)\n']);
    sig = p;
    break
  end
end

if sig==0
  fprintf(['Not significant at P=' num2str(ps(end)) ' (' num2str(ntails) '-tailed)\n']);
end
