function v_hat = NRF_model(X_fht,theta)
% v_hat = NRF_model(X_fht,theta)
% X_fht tensor of stimuli data
% theta is a cell array of network parameters

% get the variables (weights and biases)
W_jk = theta{1};
W_ij = theta{2};
b_k = theta{3};
b_j = theta{4};

I = size(W_ij,2);
   
% get the data
T = size(X_fht,3);
vin = reshape(X_fht,I,T);

for t = 1:T
    z_j = W_ij * vin(:,t) + b_j;
    uact(:,t) = z_j;
    fsig_zj=fsigmoid(z_j);
    u_j(:,t) = fsig_zj;

    z_k = W_jk*u_j(:,t) + b_k;
    vact(:,t) = z_k;
    fsig_zk=fsigmoid(z_k);
    v_hat(:,t) = fsig_zk;
end
end
