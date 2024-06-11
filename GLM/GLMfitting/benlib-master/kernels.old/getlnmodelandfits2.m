function model = getlnmodelandfits(data, z_t, fit, pred)
% function model = getlnmodelandfits(z_fit, y_fit, sigpower_fit, z_pred, y_pred, sigpower_pred)

fitdata.y_t = data.y_t(fit.idx);
fitdata.z_t = z_t(fit.idx);

% initialise fit params
fitparams.restarts = 16;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @lnmodel;

% data driven starting values (could also be used as priors)
zrange = iqr(fitdata.z_t);
zmean = mean(fitdata.z_t);
yrange = iqr(fitdata.y_t);
ymin = prctile(fitdata.y_t, 25);

%a ~ Exp(ymin + 0.05) 
%b ~ Exp(yrange * 2) % not using *2
%c ~ N(zmean, zrange ^ 2)
%d ~ Exp(0.1 * zrange)
fitparams.x0fun = {@() exprnd(ymin+0.05) @() exprnd(yrange) ...
       			     @() (randn*zrange)+zmean @() exprnd(0.1*zrange)};
fitparams.params = {[], [], [], [], [-Inf -Inf -Inf -Inf], [], []};

model = fitmodel3(fitparams, fitdata);
model = rmfield(model, 'fit');

% get y_hat for all data
alldata.y_t = data.y_t;
alldata.z_t = z_t;

model.y_hat = lnmodel(model.params, alldata);

[model.fit.sp_exp, model.fit.cc] = ...
	testfit2(data.y_t(fit.idx), model.y_hat(fit.idx), fit.sigpower);

[model.pred.sp_exp, model.pred.cc] = ...
	testfit2(data.y_t(pred.idx), model.y_hat(pred.idx), pred.sigpower);

