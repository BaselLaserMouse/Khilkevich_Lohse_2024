function result = fitmodel4_minFunc(fitparams, fitdata)
% function result = fitmodel3(fitparams, data)
%
% Fit a model using fmincon and least-squares error function
%
% Inputs:
%  fitparams.restarts -- number of restarts
%  fitparams.x0fun -- cell array of functions to produce starting values
%  fitparams.model -- function handle of function to fit
%  fitparams.errorfunc -- function handle of function providing error and partial derivatives of above
%  fitparams.options -- options structure from optimset
%  data -- data to pass to fitparams.model

res = struct;
for ii = 1:fitparams.restarts % n restarts with different initial conditions

  % starting values
  for jj = 1:length(fitparams.x0fun)
    res(ii).x0(jj) = fitparams.x0fun{jj}();
  end
  res(ii).x0 = res(ii).x0(:);

  %   options = [];
  options.display = 'none';
  options.maxFunEvals = 25;
  options.Method = 'lbfgs'; %'cg'

  % do fitting
  [res(ii).params, res(ii).sqerr] = minFunc(@fitparams.errorfunc, res(ii).x0, options,fitdata);
  %res(ii).params = fmincon(@(x) ...
  %         sum((fitparams.model(x,fitdata)-fitdata.y_t).^2), ...
  %         res(ii).x0, fitparams.params{:}, fitparams.options);
  res(ii).params = res(ii).params(:)'; % minFunc takes columns, bens code takes rows
  res(ii).yhat = fitparams.model(res(ii).params, fitdata);
  %res(ii).sqerr = sum((res(ii).yhat-fitdata.y_t).^2);

  % progress bar
  if mod(ii,ceil(fitparams.restarts/10))==0
    fprintf('.');
  end

end

% choose the best of the n restarts
sqerr = [res(:).sqerr];
f = find(sqerr==min(sqerr), 1);
result.params = res(f).params;
result.fit.yhat = res(f).yhat;
result.fit.sqerr = res(f).sqerr;

% mean([res(:).x0], 2)
% std([res(:).x0], 0, 2)
% keyboard

result.restarts = res;
