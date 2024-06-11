function model = getgainmodellinmap(z_t, y_t, ln_model)
% function model = getgainmodellinmap(x, y, ln_model)

fitdata.z_t = z_t;
fitdata.y_t = y_t;
fitdata.lnmodel = ln_model;

% initialise fit params
fitparams.restarts = 1000;
fitparams.options = optimset('Algorithm', 'sqp', 'Display', 'off');
fitparams.model = @gainmodellinmap;
fitparams.errorfunc = @gainmodellinmapSSE_partials;


z_range = range(z_t);
y_range = range(y_t);
fitparams.x0fun = {@() randn()*z_range @() randn()*y_range @() randn()*5};
fitparams.params = {[], [], [], [], [], [], []};

model = fitmodel6_minFunc(fitparams, fitdata);

% if any(abs(model.params-lb)<eps)
%     fprintf('getlnmodel: hit lower bounds:\n');
%     model.params
%     lb
% end

% if any(abs(model.params-ub)<eps)
%     fprintf('getlnmodel: hit upper bounds\n');
%     model.params
%     ub
% end
