function [beta,stopcode]=gagordy(funstr,parspace,options,p1,p2,p3,p4,p5,p6,p7,p8,p9)
%[beta,stopcode]=ga(funstr,parspace,options,p1,p2,p3,p4,p5,p6,p7,p8,p9)
% Genetic Algorithm for function maximization.
% Especially useful for functions with kinks and discontinuities,
% and where a good "starting point" is unavailable.
%    See Dorsey and Mayer, 
%    Journal of Business and Economic Statistics, January 1995, 13(1)
% Program by Michael Gordy <<A HREF="mailto:m1mbg00@frb.gov">m1mbg00@frb.gov</A>>
% Version 1.12, 7 February 1996
%
% OUTPUTS:
%  beta       = (1 x K) parameter vector maximizing funstr
%  stopcode   = code for terminating condition
%                == 1 if terminated normally
%                == 2 if maximum number of iterations exceeded
%
% INPUTS:
%  funstr     = name of function to be maximized (string).
%  parspace   = (2 x K) matrix is [min; max] of parameter space dimensions
%               or, if (3 x K), then bottom row is a good starting value
%  options    = vector of option settings
%  p1,p2,...,p9 are optional parameters to be passed to funstr
%
% where:
% options(1) = m (size of generation, must be even integer)
% options(2) = eta (crossover rate in (0,1); use Booker's VCO if < 0)
% options(3) = gamma (mutation rate in (0,1))
% options(4) = printcnt (print status once every printcnt iterations)
%                Set printcnt to zero to suppress printout.
% options(5) = maxiter (maximum number of iterations)
% options(6) = stopiter (minimum number of gains < epsln before stop)
% options(7) = epsln (smallest gain worth recognizing)
% options(8) = rplcbest (every rplcbest iterations, insert best-so-far)
% options(9) = 1 if function is vectorized (i.e., if the function
%                can simultaneously evaluate many parameter vectors).
%    Default option settings: [20,-1,0.12,10,20000,2000,1e-4,50,0]
%
% Note: 
%    The function is maximized with respect to its first parameter,
%    which is expressed as a row vector.
%    Example: 
%      Say we want to maximize function f with respect to vector p,
%      and need also to pass to f data matrices x,y,z.  Then,
%      write the function f so it is called as f(p,x,y,z).  GA will
%      assume that p is a row vector.

gaver='1.12';
defopt=[24,-1,0.12,10,20000,2000,1e-4,50,0];
months = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';...
          'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];

if nargin>2
   if isempty(options)
	options=defopt;
   end
else
   options=defopt;
end
m=options(1); eta=options(2); gam=options(3);
printcnt=options(4);
maxiter=options(5);
stopiter=options(6); epsln=options(7);
rplcbest=options(8);
vecfun=options(9);

% Use Booker's VCO if eta==-1
vco=(eta<0);  eta=abs(eta);

% Cancel rplcbest if <=0
if rplcbest<=0, rplcbest=maxiter+1; end

K=size(parspace,2);

% Draw initial Generation
G=rand(m,K).*(parspace(2*ones(m,1),:)-parspace(ones(m,1),:))...
       +parspace(ones(m,1),:);
b0rows=size(parspace,1)-2;
if b0rows>0
  G(1:b0rows,:)=parspace(3:b0rows+2,:);
  parspace=parspace([1 2],:);
end

% Initial 'best' holders
inarow=0;
bestfun=-Inf; beta=zeros(1,K);

% Score for each of m vectors
f=zeros(m,1);

% Setup function string for evaluations
paramstr=',p1,p2,p3,p4,p5,p6,p7,p8,p9';
evalstr = [funstr,'(G'];
if ~vecfun
	evalstr=[evalstr, '(i,:)'];
end
if nargin>3, evalstr=[evalstr,paramstr(1:3*(nargin-3))]; end
evalstr = [evalstr, ')'];

% Print header
if printcnt>0
   disp(['GA (Genetic Algorithm), Version ',gaver,' by Michael Gordy'])
   disp(['Maximization of function ',funstr])
   disp('i      = Current generation')
   disp('best_i = Best function value in generation i')
   disp('best   = Best function value so far')
   disp('miss   = Number of generations since last hit')
   disp('psi    = Proportion of unique genomes in generation')
   disp(sprintf(['\n',blanks(20),'i     best_i        best     miss   psi']))
end

iter=0;  stopcode=0;
oldpsi=1;  % for VCO option
while stopcode==0
   iter=iter+1;
   % Call function for each vector in G
   if vecfun
	f=eval(evalstr);
   else
     for i=1:m
	f(i)=eval(evalstr);
     end
   end
   f0=f;
   [bf0,bx]=max(f);
   bf=max([bf0 bestfun]);
   fgain=(bf-bestfun);
   if fgain>epsln
	inarow=0;
   else
        inarow=inarow+1;
   end
   if fgain>0
	bestfun=bf;
	beta=G(bx(1),:);
   end
   if printcnt>0 & rem(iter,printcnt)==1
	psi=length(unique(G))/m;
	ck=clock;
        ckhr=int2str(ck(4)+100);  ckday=int2str(ck(3)+100);
        ckmin=int2str(ck(5)+100); cksec=int2str(ck(6)+100);
	timestamp=[ckday(2:3),months(ck(2),:),' ',...
           ckhr(2:3),':',ckmin(2:3),':',cksec(2:3),' '];
	disp([timestamp,sprintf('%6.0f %8.5e %8.5e %5.0f %5.3f',...
		[iter bf0 bestfun inarow psi])])
	save gabest beta timestamp iter funstr
   end
   % Reproduction
   f=(f-min(f)).^(1+log(iter)/100);
   pcum=cumsum(f)/sum(f);
   r=rand(1,m); r=sum(r(ones(m,1),:)>pcum(:,ones(1,m)))+1;
   G=G(r,:);
   % Crossover
   if vco
	psi=length(unique(G))/m;
	eta=max([0.2 min([1,eta-psi+oldpsi])]);
	oldpsi=psi;
   end   
   y=sum(rand(m/2,1)<eta);
   if y>0
     % choose crossover point
     x=floor(rand(y,1)*(K-1))+1;
     for i=1:y
	tmp=G(i,x(i)+1:K);
	G(i,x(i)+1:K)=G(i+m/2,x(i)+1:K);
	G(i+m/2,x(i)+1:K)=tmp;
     end
   end
   % Mutation
   M=rand(m,K).*(parspace(2*ones(m,1),:)-parspace(ones(m,1),:))...
       +parspace(ones(m,1),:);
   domuta=find(rand(m,K)<gam);
   G(domuta)=M(domuta);
   % Once every rplcbest iterations, re-insert best beta
   if rem(iter,rplcbest)==0
	G(m,:)=beta;
   end
   stopcode=(inarow>stopiter)+2*(iter>maxiter);
end

if printcnt>0
   if stopcode==1
	disp(sprintf('GA: No improvement in %5.0f generations.\n',stopiter))
   else
	disp(sprintf('GA: Maximum number of iterations exceeded.\n'))
   end
end
% end of GAGordy.M
