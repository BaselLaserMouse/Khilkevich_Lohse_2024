function model = fit_sigmoid(x, y)
% function model = getlnmodel(x, y)
% fit a logistic sigmoid to the relationship between
% x and y

fitdata.y = y;
fitdata.x = x;

% initialise fit params
fitparams.restarts = 10;
fitparams.options = optimset('Algorithm', 'sqp', 'Display', 'off');
fitparams.model = @sigmoidresp;
fitparams.errorfunc = @sigmoidSSE_partials2;

% data driven starting values (could also be used as priors)
xrange = iqr(x);
if xrange==0
  xrange = 0.001;
end
xmean = mean(x);
yrange = iqr(y);
ymin = prctile(y, 5);

%a ~ Exp(ymin + 0.05) 
%b ~ Exp(yrange * 2) % not using *2
%c ~ N(xmean, xrange ^ 2)
%d ~ Exp(0.1 * xrange) (minimum at 0.1)
j = .05;
fitparams.x0fun = {@() ymin*(1+j*randn) @() yrange*10*(1+j*randn) ...
       			     @() xmean+randn*xrange @() xrange*(1+j*randn)};

% example starting value (for debugging)
for jj = 1:length(fitparams.x0fun)
  x0(jj) = fitparams.x0fun{jj}();
end
fprintf('st: %0.2f %0.2f %0.2f %0.2f\n', x0);


% constraints
y_min = min(y);
y_max = max(y);
y_range = range(y);
x_min = min(x);
x_max = max(x);
x_range = range(x);

% bounds are intended to be rather generous
%lb = [y_min-3*y_range 0 x_min-3*x_range -1000]; % lower bounds
%ub = [y_max+3*y_range 10*y_range x_max+3*x_range 1000]; % upper bounds

fitparams.params = {[], [], [], [], [], [], []};

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
