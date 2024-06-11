function result = fitmodel6_minFunc(fitparams, fitdata)
% function result = fitmodel6_minFunc(fitparams, fitdata)
%
% Fit a model using fmincon and least-squares error function
%
% Inputs:
%  fitparams.restarts -- number of restarts
%  fitparams.x0fun -- cell array of functions to produce starting values
%  fitparams.modelfunc (optional) -- function handle of function to fit
%  fitparams.errorfunc -- function handle of function providing error and partial derivatives of above
%  fitparams.options -- options structure from optimset
%  fitdata -- data to pass to fitparams.model

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
  [res(ii).params, res(ii).err] = minFunc(@fitparams.errorfunc, res(ii).x0, options, fitdata);
  res(ii).params = res(ii).params(:)'; % minFunc takes columns, bens code takes rows

  if isfield(fitparams, 'modelfunc')
    res(ii).yhat = fitparams.modelfunc(res(ii).params, fitdata);
  end

  % progress bar
  if mod(ii,ceil(fitparams.restarts/10))==0
    fprintf('.');
  end

end

% choose the best of the n restarts
err = [res(:).err];
f = find(err==min(err), 1);
result.params = res(f).params;

if isfield(res(f), 'yhat')
  result.fit.yhat = res(f).yhat;
end
result.fit.err = res(f).err;

result.restarts = res;
