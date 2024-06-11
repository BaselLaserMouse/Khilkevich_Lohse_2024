function result = fitmodel6_fmincon(fitparams, fitdata)
% function result = fitmodel6_fmincon(fitparams, data)
%
% Fit a model using fmincon and least-squares error function
%
% Inputs:
%  fitparams.restarts -- number of restarts
%  fitparams.x0fun -- cell array of functions to produce starting values
%  fitparams.model -- function handle of function to fit
%  fitparams.options -- options structure from optimset
%  data -- data to pass to fitparams.model

res = struct;
for ii = 1:fitparams.restarts % n restarts with different initial conditions

  % starting values
  for jj = 1:length(fitparams.x0fun)
    res(ii).x0(jj) = fitparams.x0fun{jj}();
  end

  % do fitting
  res(ii).params = fmincon(@(x) ...
           sum((fitparams.model(x,fitdata)-fitdata.y_t).^2), ...
           res(ii).x0, fitparams.params{:}, fitparams.options);
  % res(ii).params = fminunc(@(x) ...
  %         sum((fitparams.model(x,fitdata)-fitdata.y_t).^2), ...
  %         res(ii).x0, fitparams.options);
  res(ii).yhat = fitparams.model(res(ii).params, fitdata);
  res(ii).err = sum((res(ii).yhat-fitdata.y_t).^2);

  % progress bar
  if mod(ii,ceil(fitparams.restarts/10))==0
    fprintf('.');
  end

end

% choose the best of the n restarts
err = [res(:).err];
f = find(err==min(err), 1);
result.params = res(f).params;
result.fit.yhat = res(f).yhat;
result.fit.err = res(f).err;

result.restarts = res;
