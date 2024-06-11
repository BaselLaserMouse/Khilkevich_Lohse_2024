function [ntrain,ntrainsps,stimtrain,stimtest,spstrain,spstest]=TrainTestSetDivide(Stim,sps,trainfrac,slen,rlen)
% Divides data into two chunks for training and test data sets

if trainfrac==1
    ntrain = slen;
    ntrainsps = rlen;
    stimtrain = Stim;
    stimtest = [];
    spstrain = sps;
    spstest = [];
else
    ntrain = ceil(trainfrac*slen);
    ntrainsps = ceil(trainfrac*rlen);
    stimtrain = Stim(1:ntrain,:);
    stimtest = Stim(ntrain+1:end,:);
    spstrain = sps(1:ntrainsps);
    spstest = sps(ntrainsps+1:end);
end
