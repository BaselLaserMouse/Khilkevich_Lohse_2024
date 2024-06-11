function [f, dfdtheta] = loss_function_NRF(theta, v, args, test)
% [f, dfdtheta] = f_df_dn(theta, v, args)
% define an objective function and gradient
% You can chosse between L1 or L2 regularisation
%---------------------------------------------------
%% preliminaries
%numdata = size(v,2)-1; %number of data points
%check if doing testing rather than training
if nargin<4
    test = 0;
end

% get the data
vin = v{1};
fq = size(vin,1)*size(vin,2);
T = size(vin,3);
vin = reshape(vin,fq,T);
vout = v{2};

%get the parameters
I = fq; % number input units
J = args{1}; % number hidden units
K = args{2}; % number of output units
lam = args{3}; % regularization constant
regtype = args{4}; % regularization type


% get the variables (weights and biases)
% if the parameters are in a cell array
if iscell(theta)
W_jk = theta{1};
W_ij = theta{2};
b_k = theta{3};
b_j = theta{4};

% if the parameters are in a matrix
else
    nn = K*J;
    W_jk = reshape(theta(1:nn),K,J);
	nnold = nn;
    nn = nnold+J*I;
    W_ij = reshape(theta((nnold+1):nn),J,I);
    nnold = nn;
    nn = nnold+K;
    b_k = reshape(theta((nnold+1):nn),K,1);
	nnold = nn;
    nn = nnold+J;
    b_j = reshape(theta((nnold+1):nn),J,1);
end

%-------------------------------------------
%% objective function
u_j=zeros(J,T);
v_hat=zeros(K,T);
dv_hat_dw_jk=zeros(J,T);
du_j_dw_ij=zeros(I,J,T);
dv_hat_dw_ij=zeros(I,J,T);
dv_hat_db_k=zeros(K,T);
du_j_db_j=zeros(J,T);
dv_hat_db_j=zeros(J,T);

for t = 1:T

z_j = W_ij * vin(:,t) + b_j;
uact(:,t) = z_j;
fsig_zj=fsigmoid(z_j);
u_j(:,t) = fsig_zj;

z_k = W_jk*u_j(:,t) + b_k;
vact(:,t) = z_k;
fsig_zk=fsigmoid(z_k);
v_hat(:,t) = fsig_zk;


% part of the derivatives
fprime_zk = fprimesigmoid(z_k);
fprime_ij = fprimesigmoid(z_j);
dv_hat_dw_jk(:,t) = u_j(:,t)*fprime_zk; % dv_hat_dw_jk
du_j_dw_ij(:,:,t) = vin(:,t)*fprime_ij';
dv_hat_dw_ij(:,:,t) = fprime_zk*bsxfun(@times,W_jk,du_j_dw_ij(:,:,t)); % dv_hat_dw_ij

dv_hat_db_k(:,t) = fprime_zk;
du_j_db_j(:,t) = fprime_ij;
dv_hat_db_j(:,t) = fprime_zk*(W_jk'.*du_j_db_j(:,t));
end

%get the squared error
a_t = v_hat - vout;
funreg = (0.5*sum(a_t.^2))/T;


%regularize
switch regtype
    
    case 'sq'
regul = lam.*sum(W_jk(:).^2) + lam.*sum(W_ij(:).^2); % + lam.*sum(b_k.^2) + lam.*sum(d_k.^2);
    case 'abs'
regul = lam.*sum(abs(W_jk(:))) + lam.*sum(abs(W_ij(:))); % + lam.*sum(b_k.^2) + lam.*sum(d_k.^2);
    case 'none'
regul = 0; 


end

f = funreg + regul; %funreg already normalised for amount of data

%----------------------------------------------
%----------------------------------------------
% derivatives of output weights and biases
dEdW_jk = sum(bsxfun(@times,dv_hat_dw_jk,a_t),2)/T;
dEdW_jk = dEdW_jk';

dEdW_ij = zeros(I,J);
for ii = 1:T
dEdW_ij = dEdW_ij + (dv_hat_dw_ij(:,:,ii)*a_t(ii));
end
dEdW_ij = dEdW_ij'/T;

dEdb_k = (dv_hat_db_k*a_t')/T;
dEdb_j = (dv_hat_db_j*a_t')/T;

% derivative of regularization
switch regtype
    case 'sq'
dEdW_jk = dEdW_jk + 2.*lam.*W_jk;
dEdW_ij = dEdW_ij + 2.*lam.*W_ij;
%dEdb = dEdb + 2.*lam.*b_k;
%dEdd = dEdd + 2.*lam.*d_k;
    case 'abs'
dEdW_jk = dEdW_jk + lam.*sign(W_jk);
dEdW_ij = dEdW_ij + lam.*sign(W_ij);
%dEdb = dEdb + lam.*sign(b_k);    
%dEdd = dEdd + lam.*sign(d_k); 
end

% give the gradients the same order as the parameters
if iscell(theta)
dfdtheta = {dEdW_jk, dEdW_ij, dEdb_k, dEdb_j};
else
    dfdtheta = [dEdW_jk(:); dEdW_ij(:); dEdb_k(:); dEdb_j(:)];
end

%----------------------------------------------
%% If testing rather than training give the predictions and other
%characteristics of the network
if test
    output.f = f;
    output.funreg = funreg;
    output.vin = vin; 
    output.uact = uact;
    output.uout = u_j;
    output.vact = vact;
    output.vhat = v_hat;
    output.vout = vout;
    f = output; 
    
end