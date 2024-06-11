function [h,p,chisquare]=chisquare(fo,Alpha)

% CHISQUARE  Hypothesis test: compares observed counts to expected
%    counts. BH 2005 (BYH version gave wrong answer!!)
%    Fixed bw sep 2005 (and checked against online chisq calculators)
%
%    [H,P]=CHISQUARE(FO,FE,ALPHA)
%    performs a chi-square test on the observed counts (FO), 
%    comparing them to the expected counts (FE). Evaluates the null
%    hypothesis (observed not different from expected) and returns 
%    a binary value:
%    H=0 => "Do not reject null hypothesis"
%    H=1 => "Reject null hypothesis at significance level of alpha.
%    
%    P gives p-value
%
%    See also ttest, randomt

if size(fo,1)~=2 | size(fo,2)~=2
  fprintf('i can only do 2x2 chisquare\n');
  h = nan;p = nan;
end

n  = repmat(sum(fo,1),[2 1]);
mn = repmat(mean(fo,2),[1,2]);

fe = mn./sum(fo(:))*n;

chisquare=(fo-fe).^2./fe;
chisquare=sum(chisquare(:));

df=length(fo)-1;
if ~exist('Alpha')
   Alpha=0.05;
end

p=chi2cdf(chisquare,df);
p=1-p;
h=p<Alpha; 
