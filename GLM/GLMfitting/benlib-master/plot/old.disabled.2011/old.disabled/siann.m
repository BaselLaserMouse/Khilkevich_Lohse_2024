function [x,u] = siann(fun,x0,scales,param,arg1,arg2,arg3,arg4,arg5)

% SIANN   Minimization by the method of "simulated annealing".
% [X,U] = SIANN(FUN,X0,SCALES,PARAM,ARG1,ARG2,...)
%       minimizes function  FUN(X,ARG1,ARG2,...) starting from
%       the value X0 of a state vector and additional optional
%       parameters ARG1,...  which are not changed in the 
%       minimization process.
%       Optional parameters:
%     SCALES - scales for each components of state vector X,
%       must be either a scalar or of the same size as X,
%       if [] the default is used;
%     PARAM  - (string) any values of control parameters can be
%       passed as  legal MATLAB expressions, which are evaluated
%       inside the program.
%       Returns attained minimum X and the corresponding value U.
%
%     Example:
%     [x,u] = siann('foo',[1 0],[],'T0=2,cool=.99')
%       minimizes function FOO starting from [1 0], initial
%       "temperature" is 2 and temperature is multiplied by .99
%       at each step.
%
%  SIANN by itself and also SIANN DEMO or SIANNDEMO run a
%       demonstration for SIANN routine.
%
%  For more information see SIANN INFO

%  Kirill K. Pankratov, kirill@plume.mit.edu
%  April 19, 1994

% Default control parameters ::::::::::::::::::::::::::::::::::::::
 % Main parameters ...............................
stop = 'try>=1000';  % Stopping condition
T0 = 1;              % "Initial temperature"
k = 1;               % Initial "Boltzman constant
cool = .996;         % Annealing multiple
step = 1;            % Number of steps in 1 try
trace  = 1;          % If to plot the process
callout = '';        % External call

average = 30;      % Control variables are averaged over this number
                   %   of tries
update = 10;       % Frequency of plot updates
check = 5;         % Frequency of amplitude and scales adjustment

long = 5;          % Frequency of "long" jumps
longjump = 5;      % Relative lengthscale of long jumps

ampjump = 1;       % Initial jump amplitude (length)
ampoffset = .4;    % Offset: "normal" correlation coef. in
                   %    amplitude adjustment
amprate = .1;      % Rate of amplitude adjustment

scalesens = .04;   % Sensitivity of relative scales adjustment for
                   %   different components 

 % Handle input arguments :::::::::::::::::::::::::::::::::::::::
if nargin==0, sianndemo; return, end
if nargin==1
  if isstr(fun)
    if strcmp(fun,'demo'), sianndemo             % Demo
    elseif strcmp(fun,'info'), type sianninfo    % Info
    end
  else
    disp([10 '  Error: flag must be a string.'])
  end
  return
end
  
if nargin>3   % Specified control parameters
  if isstr(param)
    for jp = 1:size(param,1)
      eval(param(jp,:));
    end
  else
    fnd = find(param>10);
    if fnd~=[], try = param(fnd(1)); end
    fnd = find(param>.9&param<1);
    if fnd~=[], cool = param(fnd(1)); end
    stop = ['try>=' num2str(try)];
  end
end
if scales==[], scales = ones(size(x0)); end
if length(scales)==1, scales = scales*ones(size(x0)); end
scales = scales+(scales<0);

if nargin>4     % Set up function call
  call = [fun '(xc' ',arg1'];
  for ja = 1:nargin-5
    call =[call ',arg' num2str(ja)];
  end
  call = [call ')'];
end

if ~isstr(cool), cool = ['T=T*' num2str(cool) ';']; end

 % Initialization .............................................
ajtr = zeros(1,average);
ujtr = ajtr;
T = T0;
x = x0;
isstop = 0; try = 1;
u0 = 1;
gainc = 1; isgotot = 0;
scaver = ones(size(x0));

if trace  % Initialize plot ................
  xpst = .5;
  ypst = .5;
  ftrace = figure('pos',[20 500 500 350]);
  pl = plot(1,1,'.y'); axis([1 1000 0 1])
  set(pl,'erasemode','none','markersize',10)
  ap = gca;
  set(ap,'drawmode','fast')
  title('Simulated annealing run')
  xlabel('Try number'), ylabel('Minimized function value')
  pos = get(ap,'pos');
  posst = [pos(1)+(1-xpst)*pos(3) pos(2)+(1-ypst)*pos(4)-.1];
  posst = [posst xpst*pos(3) ypst*pos(4)];
  ast = axes('pos',posst,'visible','off','drawmode','fast');
  title('Current state:')
  tst(1,1) = text(.0,.9,'Try');
  tst(1,2) = text(.6,.9,'1');
  tst(2,1) = text(.0,.8,'Success ratio');
  tst(2,2) = text(.6,.8,'0');
  tst(3,1) = text(.0,.7,'gain');
  tst(3,2) = text(.6,.7,'0');
  tst(4,1) = text(.0,.6,'rate');
  tst(4,2) = text(.6,.6,'0');
  tst(5,1) = text(.0,.5,'T');
  tst(5,2) = text(.6,.5,num2str(T0));
  tst(6,1) = text(.0,.4,'k');
  tst(6,2) = text(.6,.4,num2str(k));
  tst(7,1) = text(.0,.3,'ampjump');
  tst(7,2) = text(.6,.3,num2str(ampjump));
  tst(8,1) = text(.0,.2,'corr. coef');
  tst(8,2) = text(.6,.2,'1');
  set(tst(:,2),'erasemode','xor')
end


while ~isstop    % Begin  annealing ````````````````````````````````0
  xc = x;
  jj = 1; isgo = 0;

  while (isgo==0)&(jj<=step) % Begin one try `````````````````````1

     % The main procedure (Metropolis) ^^^^^^^^^^^^^^^^^^
    if rem(try,long), jumplength = 1;
    else, jumplength = longjump;
    end

    xjump = ampjump*randn(size(x0))*rand(1)*jumplength;
    xjump = xjump.*scales*T/T0;
    xc = xc+xjump;

    if nargin>4
      u = eval(call);      % Call evaluation
    else
      u = feval(fun,xc);   % Function evaluation
    end
    if try==1              
      if trace, set(pl,'ydat',u), end
      u0 = u; u00 = u;
    end

    du0 = u-u0;
    Bc = rand(1);                  % Value to compare
    B = exp(-du0/(k*T));           % Boltzman function
    isgo = (B>1)|(B>Bc&jj==step);  % Go or stay
    jj = jj+1;                     % Next step

     % Adjust the scales for each component of state vector xjump
    scaver = scaver*(average-1)/average;
    scaver = scaver+du0*xjump./sqrt(scales)/average;
    if ~rem(try,check)     % Adjust the scales
      scales = scales./(1+scalesens*abs(scaver)/mean(abs(scaver)));
      scales = scales*(1+scalesens);
    end

     % Adjust the jump amplitude .................
    ajc = sqrt(sum(xjump(:).^2));       % Current length
    ajtr = [ajtr(2:average) ajc];       % Update the jump lenthes
    ujtr = [ujtr(2:average) abs(u-u0)]; % Update the jump heights
    if ~rem(try,check)  % Adjust jump amplitude
      cc = abs(corrcoef(ajtr,ujtr));
      ampjump = ampjump*(1+(cc(2,1)-ampoffset)*amprate);
    end
  
     % Adjust the "Boltzman's constant" ..........
    k = k*(average-T/T0)/average+abs(du0)*T/T0/average;
  end  % End one try  '''''''''''''''''''''''''''''''''''''''''1

   % Change "temperature" ........................
  eval(cool);

   % Diagnostics .................................
  isgotot = isgotot+isgo;   % Total number of successful jumps
  succratio = isgotot/try;  % Relative number of successful jumps

  gainc = gainc*(average-1)/average+(u0-u)/average;
  gain = u00-u;         % Total decrease in objective function
  rate = gainc/(gain+(gain==0));     % Recent rate of decrease

   % Plotting ....................................
  if trace
    ydat = get(pl,'ydat');
    ylim = [min(ydat) max(ydat)]; ysc = ylim(2)-ylim(1);
    set(pl,'xdata',[get(pl,'xdat') try],'ydata',[ydat u])
    if ~rem(try,update)
      set(pl,'erasemode','back')
      set(pl,'xdata',get(pl,'xdat'),'ydata',get(pl,'ydat'))
      drawnow, set(pl,'erasemode','none')
      set(ap,'ylim',[ylim(1)-ysc*.1 ylim(2)+ysc*.1])
      set(ap,'xlim',[0 max(1000,ceil(try/100)*100)])
      set(tst(1,2),'string',num2str(try))
      set(tst(2,2),'string',num2str(succratio))
      set(tst(3,2),'string',num2str(gain))
      set(tst(4,2),'string',num2str(rate))
      set(tst(5,2),'string',num2str(T))
      set(tst(6,2),'string',num2str(k))
      set(tst(7,2),'string',num2str(ampjump))
      set(tst(8,2),'string',num2str(cc(2,1)))
    end
    drawnow
  end

  eval(callout)               % Evaluate external call
  isstop = eval(stop);        % Evaluate stopping condition

  x = (x*(1-isgo))+(xc*isgo);   % Choose to go or stay
  try = try+1;                  % Next try
  u0 = u;                       % Shift

end    % End annealing routine '''''''''''''''''''''''''''''''''''''0
