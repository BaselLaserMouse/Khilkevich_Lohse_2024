function model = getlnmodelandfits(z_fit, y_fit, sigpower_fit, z_pred, y_pred, sigpower_pred)
% function model = getlnmodelandfits(z_fit, y_fit, sigpower_fit, z_pred, y_pred, sigpower_pred)

fitdata.y_t = y_fit;
fitdata.z_t = z_fit;

% initialise fit params
fitparams.restarts = 20;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @lnmodel;

% data driven starting values (could also be used as priors)
zrange = iqr(z_fit);
zmean = mean(z_fit);
yrange = iqr(y_fit);
ymin = prctile(y_fit, 25);

%a ~ Exp(ymin + 0.05) 
%b ~ Exp(yrange * 2) % not using *2
%c ~ N(zmean, zrange ^ 2)
%d ~ Exp(0.1 * zrange)
fitparams.x0fun = {@() exprnd(ymin+0.05) @() exprnd(yrange) ...
       			     @() (randn*zrange)+zmean @() exprnd(0.1*zrange)};
fitparams.params = {[], [], [], [], [0 0 -Inf 0], [], []};

model = fitmodel3(fitparams, fitdata);
model.fit.y_hat = lnmodel(model.params, fitdata);
[model.fit.sp_exp, model.fit.cc] = ...
	testfit2(y_fit, model.fit.y_hat, sigpower_fit);

%%
preddata.y_t = y_pred;
preddata.z_t = z_pred;
model.pred.y_hat = lnmodel(model.params, preddata);

[model.pred.sp_exp, model.pred.cc] = ...
	testfit2(y_pred, model.pred.y_hat, sigpower_pred);