function model = getttcmodel(dt, z_fit, C_ht_fit, y_fit, threshmodel)
% function model = getttcmodel(z_fit, C_ht_fit, y_fit)

% fit tau only -- other parameters fixed to values from gainmodel

fitdata.dt = dt;
fitdata.y_t = y_fit;
fitdata.z_t = z_fit;
fitdata.C_ht = C_ht_fit;

% initialise fit params
fitparams.restarts = 2;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @ttcmodel;

n_h = size(fitdata.C_ht, 1);
h_max = (n_h-1)*dt;

p = threshmodel.params;

% jitter the starting values from the ln model
fitparams.x0fun = {@() p(1) ...
            @() p(2) ...
            @() p(3) ...
            @() p(4) ...
            @() p(5) ...
            @() rand*h_max/2 ...
            @() 0};

lb = [-Inf 0 -Inf -Inf 0 0 0];
ub = [+Inf +Inf +Inf +Inf +Inf h_max/2 0];

fitparams.params = {[], [], [], [], lb, ub, []};

model = fitmodel3(fitparams, fitdata);
