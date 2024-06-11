function [ntrain,ntrainsps,stimtrain,stimtest,spstrain,sps2train,spstest,sps2test]=TrainTestSetDivideCoupling(Stim,sps,sps2,trainfrac,slen,rlen)
% Divides data into two chunks for training and test data sets

if trainfrac==1
    ntrain = slen;
    ntrainsps = rlen;
    stimtrain = Stim;
    stimtest = [];
    spstrain = sps;
    sps2train = sps2;
    spstest = [];
    sps2test=[];
else
    ntrain = round(trainfrac*slen);
    ntrainsps = round(trainfrac*rlen);
    stimtrain = Stim(1:ntrain,:);
    stimtest = Stim(ntrain+1:end,:);
    spstrain = sps(1:ntrainsps);
    sps2train = sps2(1:ntrainsps,:);
    spstest = sps(ntrainsps+1:end);
    sps2test = sps2(ntrainsps+1:end,:);

end