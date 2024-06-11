function model = getgtcmodel2(dt, z_fit, C_ht_fit, y_fit, gainmodel)
% function model = getgtcmodel(z_fit, C_ht_fit, y_fit)

% allow params to be refit

fitdata.dt = dt;
fitdata.y_t = y_fit;
fitdata.z_t = z_fit;
fitdata.C_ht = C_ht_fit;

% initialise fit params
fitparams.restarts = 2;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @gtcmodel;

n_h = size(fitdata.C_ht, 1);
h_max = (n_h-1)*dt;

p = gainmodel.params;

% jitter the starting values from the ln model
fitparams.x0fun = {@() p(1)*(.95+(rand*.1)) ...
            @() p(2)*(.95+(rand*.1)) ...
            @() p(3)*(.95+(rand*.1)) ...
            @() p(4)*(.95+(rand*.1)) ...
            @() p(5)*(.95+(rand*.1)) ...
            @() p(6)*(.95+(rand*.1)) ...
            @() rand*h_max/2 ...
            @() 0};

lb = [-Inf 0 -Inf -Inf 0 0 0 0];
ub = [+Inf +Inf +Inf +Inf +Inf +Inf h_max 0];

fitparams.params = {[], [], [], [], lb, ub, []};

model = fitmodel3(fitparams, fitdata);
