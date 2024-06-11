function result = fitmodel(fp, data)
% function result = fitmodel(fp, data)
% 
% Fit a model using fmincon and least-squares error function
% 
% Inputs:
%  fp.restarts -- number of restarts
%  fp.x0fun -- cell array of functions to produce starting values
%  fp.model -- function handle of function to fit
%  fp.options -- options structure from optimset
%  data -- data to pass to fp.model

res = struct;
for ii = 1:fp.restarts % n restarts with different initial conditions
  
  % starting values
  for jj = 1:length(fp.x0fun)
    res(ii).x0(jj) = fp.x0fun{jj}();
  end
  
  % do fitting
  res(ii).params = fmincon(@(x) ...
          sum((fp.model(x,data)-data.y_t).^2), ...
          res(ii).x0, fp.params{:}, fp.options);
  res(ii).yhat = fp.model(res(ii).params, data);
  res(ii).sqerr = sum((res(ii).yhat-data.y_t).^2);

  % progress bar
  if mod(ii,ceil(fp.restarts/10))==0
    fprintf('.');
  end

end

fprintf('\n');

% choose the best of the n restarts
sqerr = [res(:).sqerr];
f = find(sqerr==min(sqerr), 1);
result.params = res(f).params;
result.fit.yhat = res(f).yhat;
result.fit.sqerr = res(f).sqerr;

result.restarts = res;
