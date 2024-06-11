function [theta,train_err] = fit_NRF_model(X_fht,y_t,minibatch_number,...
    regtype,lam,net_str,num_pass,theta_init)
% [theta,train_err] = fit_NRF_model(X_fht,y_t,minibatch_number,...
%    regtype,lam,net_str,num_pass,theta_init)
%
% This is an implementation of NRF model (similar to Harper et. al. 2016)
% with sigmoid non-linearity
%
% regtype : 'abs' or 'sq'
% lam: anything from 0 to 1
% num_pass: number of iteration through data, 20 is fine
% theta_init: initial value of network parameters
% 
% most of parameters have got default values. So the the model will train
% with only X_fht and y_t
%
% Author: Monzilur Rahman
% Year: 2016
% monzilur.rahman@gmail.com
%

% set defaults
% Network structure
if ~exist('net_str','var')
    J= 20; % number of hidden units
    K = 1; % number of output units
else
    J = net_str{1};
    K = net_str{2};
end

if ~exist('regtype','var')
    regtype='abs'; % regularization type
end

if ~exist('lam','var')
    lam=1e-5;
end

if ~exist('num_pass')
    num_pass = 20;
end

if ~exist('minibatch_number','var')
    minibatch_number = 20;
end

args = {J,K,lam,regtype};
I = size(X_fht,1)*size(X_fht,2);

% Initialization of network parameters
if ~exist('theta_init','var')
    rng('shuffle');
    C = 0.5;
    W_jk = C*2*(rand(K,J)-0.5)/sqrt(J+K);
    W_ij = C*2*(rand(J,I)-0.5)/sqrt(I+J);
    b_k = C*2*(rand(K,1)-0.5)/sqrt(J+K);
    b_j = C*2*(rand(J,1)-0.5)/sqrt(I+J);
    
    theta_init = {W_jk,W_ij,b_k,b_j};
end

% Make minibatches
batch_size = floor(length(y_t)/minibatch_number);
for minibatch = 1:minibatch_number
    startInd = (minibatch-1)*batch_size + 1;
    endInd = (minibatch-1)*batch_size + batch_size ;
    sub_refs{minibatch}{1} = X_fht(:,:,startInd:endInd);
    sub_refs{minibatch}{2} = y_t(startInd:endInd);
end

% initialize the optimizer
optimizer = sfo(@loss_function_NRF,theta_init,sub_refs,args);
% run the optimizer for half a pass through the data
theta = optimizer.optimize(0.5);
% run the optimizer for another 20 passes through the data, continuing from 
% the theta value where the prior call to optimize() ended
theta = optimizer.optimize(num_pass);

train_err = optimizer.hist_f_flat;
end