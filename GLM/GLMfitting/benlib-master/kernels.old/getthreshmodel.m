function model = getthreshmodel(z_fit, C_fit, y_fit, lnmodel)
% function model = getthreshmodel(z_fit, y_fit)

% model where c and d can change, but only c has c_L and c_H for
% low and high contrast

fitdata.y_t = y_fit;
fitdata.z_t = z_fit;
fitdata.C_t = C_fit;

% initialise fit params
fitparams.restarts = 6;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @threshmodel;

% jitter the starting values from the ln model
fitparams.x0fun = {@() lnmodel.params(1)*(.95+(rand*.1)) ...
            @() lnmodel.params(2)*(.95+(rand*.1)) ...
            @() lnmodel.params(3)*(.95+(rand*.1)) ...
            @() lnmodel.params(3)*(.95+(rand*.1)) ...
            @() lnmodel.params(4)*(.95+(rand*.1))};

fitparams.params = {[], [], [], [], ...
	[-Inf 0 -Inf -Inf 0], ...
	[Inf Inf Inf Inf +Inf], []};

model = fitmodel3(fitparams, fitdata);
