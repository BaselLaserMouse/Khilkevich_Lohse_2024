function model = getgainmodel(z_fit, C_fit, y_fit, lnmodel)
% function model = getgainmodel(z_fit, y_fit)

fitdata.y_t = y_fit;
fitdata.z_t = z_fit;
fitdata.C_t = C_fit;

% initialise fit params
fitparams.restarts = 6;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.modelfunc = @gainmodel3free;
fitparams.errorfunc = @gainmodel3freeSSE_partials;

% jitter the starting values from the ln model
fitparams.x0fun = {@() lnmodel.params(1)*(.95+(rand*.1)) ...
            @() lnmodel.params(1)*(.95+(rand*.1)) ...
            @() lnmodel.params(2)*(.95+(rand*.1)) ...
            @() lnmodel.params(3)*(.95+(rand*.1)) ...
            @() lnmodel.params(3)*(.95+(rand*.1)) ...
            @() lnmodel.params(4)*(.95+(rand*.1)) ...
            @() lnmodel.params(4)*(.95+(rand*.1))};

fitparams.params = {[], [], [], [], [-Inf -Inf 0 -Inf -Inf 0 0], [], []};

model = fitmodel6_minFunc(fitparams, fitdata);
