function model = getgainmodel2014(z_fit, C_fit, y_fit)
% function model = getgainmodel2014(z_fit, C_fit, y_fit)
% Fit a sigmoid model in which a, b are constant, but c, d can vary with contrast

fitdata.y_t = y_fit;
fitdata.C_t = C_fit;
fitdata.z_t = z_fit;

% initialise fit params
fitparams.restarts = 100;
fprintf('Only 5 restarts!\n')
fitparams.options = optimset('Algorithm', 'sqp', 'Display', 'off');
fitparams.model = @gainmodel2014;
fitparams.errorfunc = @gainmodel2014error;

% data driven starting values (could also be used as priors)
zmin = prctile(z_fit, 5);
zrange = iqr(z_fit);
if zrange==0
  zrange = 0.001;
end
zmean = mean(z_fit);
yrange = iqr(y_fit);
ymin = prctile(y_fit, 25);

%a ~ Exp(ymin + 0.05) 
%b ~ Exp(yrange * 2) % not using *2
%c ~ N(zmean, zrange ^ 2)
%d ~ Exp(0.1 * zrange) (minimum at 0.1)
%e ~ N(0, zmean/5)
%f ~ Exp(0.02 * zrange)
% fitparams.x0fun = {@() exprnd(ymin+0.05) @() exprnd(yrange) ...
%                  @() (randn*zrange)+zmean @() max(exprnd(0.1*zrange),0.1) ...
%                  @() randn+zmean/5 @() max(exprnd(0.02*zrange), 0.02) };

j = .1;
fitparams.x0fun = {@() ymin*(1+j*randn) @() yrange*(1+j*randn) ...
       			   @() zmean+randn*zrange @() zrange*(1+j*2*randn) ...
       			   @() zmin+randn*zrange @() randn*zrange};

% fitparams.x0fun = {@() ymin*(1+j*randn) @() yrange*(1+j*randn) ...
%        			     @() zmean+randn*zrange @() zrange*(1+j*2*randn) ...
%        			    @() randn+zmean/10 @() max(exprnd(0.02*zrange*10), 0.02) };

for jj = 1:length(fitparams.x0fun)
    x0(jj) = fitparams.x0fun{jj}();
end
x0

% constraints
y_min = min(y_fit);
y_max = max(y_fit);
y_range = range(y_fit);
z_min = min(z_fit);
z_max = max(z_fit);
z_range = range(z_fit);

% bounds are intended to be rather generous
lb = [y_min-3*y_range 0          z_min-3*z_range  .01 z_min-3*z_range -10]; % lower bounds
ub = [y_max+3*y_range 10*y_range z_max+3*z_range 1000 z_max+3*z_range 10]; % upper bounds

%fitparams.params = {[], [], [], [], lb, ub, []};
fitparams.params = {[], [], [], [], [], [], []};
%fprintf('Ignoring bounds\n');
model = fitmodel5_minFunc(fitparams, fitdata);

% if any(abs(model.params-lb)<eps)
% 	fprintf('getlnmodel: hit lower bounds:\n');
% 	model.params
% 	lb
% end
% 
% if any(abs(model.params-ub)<eps)
% 	fprintf('getlnmodel: hit upper bounds\n');
% 	model.params
% 	ub
% end
