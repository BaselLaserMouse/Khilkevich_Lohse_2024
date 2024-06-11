function [beta,beta0,lambda_opt] = qnlasso(sctr,rctr,cvi)
% function [beta,beta0,lambda_opt] = qnlasso(sctr,rctr,cvi)
%
% NH 2013
% lasso using minFunc (Quasi-Newton minimisation).
% sctr = training and validation inputs
% rctr = training and validation outputs
% cvi = validation indices


%objective function
m1obj = @gradlasso;
hfmax = size(sctr,1);
betavec_init = zeros(hfmax+1,1);
temp = [];

%-------------------------------------------------------------------------


%parameters
startstepsize = 0.5;
stopstepsize = 0.3;
stepsize = 0.5;
loglam = [7 7.5 8];
lam=0;
numpairs = 0;
maxnumpairs = 3;
pred = 0;
options.MaxIter = 500;
options.Display = 'final';

%split into training and validation sets
sccv = sctr(:,cvi);
rccv = rctr(cvi);
sctr(:,cvi) = [];
rctr(cvi) = [];

%get ballpark lambda
X = sctr';
Y = rctr';
alpha = 1; % lasso
[N,P] = size(X);
muY = mean(Y);
Y0 = bsxfun(@minus,Y,muY);
[X0,~,~] = zscore(X,1);
dotp = abs(X0' * Y0);
lambdaMax = max(dotp) / (N*alpha);
clear X Y

loglamBase = log(0.31.*lambdaMax);%0.31 is a hack
loglam = loglamBase - [2 1.5 1 0.5];


%home in on correct lambda
while lam < length(loglam)
    lam = lam+1;
    
    lambda = exp(loglam(lam));
    
    disp(['Minimizing for lambda ' num2str(lambda)])
    
    %minimize
    betavec = minFunc(m1obj,betavec_init,options, sctr, rctr, lambda, pred);
    
    %get cv prediction
    pred = 1;
    mse_cv = m1obj(betavec,sccv,rccv,lambda, pred);
    pred = 0;
    
    %collate
    mse_list(lam) = mse_cv;
    betavec_list(:,lam) = betavec;
    
    
    
    %make new loglam
    if (lam==length(loglam)) && (stepsize>stopstepsize);
        numpairs = numpairs +1;
        [minmse minmsei] = min(mse_list);
        [minlam minlami] = min(loglam);
        [maxlam maxlami] = max(loglam);
        if minmsei==minlami
            loglam = [loglam (loglam(minmsei)-stepsize) (loglam(minmsei)-2.*stepsize)];
            
        elseif minmsei==maxlami
            loglam = [loglam (loglam(minmsei)+stepsize) (loglam(minmsei)+2*stepsize)];
            
        else
            stepsize = stepsize./2;
            loglam = [loglam (loglam(minmsei)-stepsize) (loglam(minmsei)+stepsize)];
        end
    end
end

%get best lambda, beta, and beta0
[minmse minmsei] = min(mse_list);
lambda_opt = exp(loglam(minmsei));
beta = betavec_list(1:(end-1),minmsei);
beta0 = betavec_list(end,minmsei);
% mse_list
% exp(loglam)
