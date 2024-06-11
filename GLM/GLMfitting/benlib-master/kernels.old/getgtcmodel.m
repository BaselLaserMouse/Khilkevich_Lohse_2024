function model = getgtcmodel(dt, z_fit, C_ht_fit, y_fit, gainmodel)
% function model = getgtcmodel(z_fit, C_ht_fit, y_fit)

% fit tau only -- other parameters fixed to values from gainmodel

fitdata.dt = dt;
fitdata.y_t = y_fit;
fitdata.z_t = z_fit;
fitdata.C_ht = C_ht_fit;
% fitdata.pause = true;

% initialise fit params
fitparams.restarts = 4;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @gtcmodel;

n_h = size(fitdata.C_ht, 1);
h_max = (n_h-1)*dt;

p = gainmodel.params;

% jitter the starting values from the ln model
fitparams.x0fun = {@() p(1) ...
            @() p(2) ...
            @() p(3) ...
            @() p(4) ...
            @() p(5) ...
            @() p(6) ...
            @() rand*h_max/2 ...
            @() 0};

lb = [p(1) p(2) p(3) p(4) p(5) p(6) 0 0];
ub = [p(1) p(2) p(3) p(4) p(5) p(6) h_max/2 0];

fitparams.params = {[], [], [], [], lb, ub, []};
model = fitmodel3(fitparams, fitdata);
