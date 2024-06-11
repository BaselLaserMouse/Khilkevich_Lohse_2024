function [fstar, xstar, state] = psoantimin2(costfunc,modelfunc,...
					     xl,xu,xw,xi,...
					     num_particles,fitdata)

% upper and lower bounds in vectorised form
xlb = repmat(xl,[num_particles,1]);
xub = repmat(xu,[num_particles,1]);

% inital positions are randomly chosen
current_params = zeros(num_particles,length(xl));
for ii = 1:num_particles
  current_params(ii,:) = rand(size(xl)).*(xu-xl)+xl;
end

% unless xi is specified, in which case we make one particle start
% at the point specified by xi
if length(xi)>0
  current_params(1,:) = xi;
end

% current merit for each particle
current_merit = -1000*ones(num_particles,1);

% best-ever merit for each particle
my_best_merit   = 0*ones(num_particles,1);

% best-ever params from each particle
my_best_params  = zeros(size(current_params));

% best-ever merit for any particle
queens_merit  = -1000;

% best-ever params for any particle
queens_params = zeros(size(xl));

% worst-ever merit for any particle
antiqueens_merit = 1000;

% worst-ever params for any particle
antiqueens_params = zeros(size(xl));

fitdata.newfit = 1;

for temp = 1:2

  if temp==1
    % set PSO params
    c1 = .6; %.2 how fast you go towards the best-so-far for this particle 
    c2 = .6; %.2 how fast you go towards the queen
    vmult = .3; %.1 multiplier to set max speed
    % initial velocity of each particle is zero
    velocity = zeros(size(current_params));

  else
    % set PSO params
    c1 = 0; % how fast you go towards the best-so-far for this particle 
    c2 = 0.1; % how fast you go towards the queen
    vmult = 0.05; % multiplier to set max speed
    % initial velocity of each particle is zero
    velocity = zeros(size(current_params));

  end

% maximum velocity
vmaxb = vmult*repmat(xu-xl,[num_particles,1]);
  
% iteration counter
iter = 0;

% function evaluation counter
num_func_evals = 0;

% how many iterations have we been through without any improvement?
num_static_its = 0;

while num_static_its<10
  iter = iter + 1;
  fprintf(['iteration ' num2str(iter) '\n']);
  
  % calculate the merit of all the current particle positions
  for ii = 1:num_particles
    current_merit(ii) = -feval(costfunc,modelfunc,current_params(ii,:), ...
			       fitdata);
    fitdata.newfit = 0;
    num_func_evals = num_func_evals + 1;
  end
  
  % which particles are now at their individual best-ever or
  % worst-ever position?
  % update their best-ever record to match
  % note 'best' really means 'most interesting' here
  improved = find(abs(current_merit > abs(my_best_merit)));
  my_best_merit = max(abs(current_merit),abs(my_best_merit));
  my_best_params(improved,:) = current_params(improved,:);

  % has the queen moved?
  if max(current_merit)>queens_merit
    queens_num = find(current_merit==max(current_merit));
    queens_num = queens_num(1); % just in case there are >1
    queens_merit  = current_merit(queens_num);
    queens_params = current_params(queens_num,:);
    fprintf(['new queen:     merit = ' num2str(queens_merit,'%1.2f') ...
	     '; params = ' num2str(queens_params,'%2.1f ') '\n']);
    queen_changed = 1;
  else 
    queen_changed = 0;
  end

  % has the antiqueen moved?
  if min(current_merit)<antiqueens_merit
    antiqueens_num = find(current_merit==min(current_merit));
    antiqueens_num = antiqueens_num(1); % just in case there are >1
    antiqueens_merit  = current_merit(antiqueens_num);
    fprintf(['new antiqueen: merit = ' num2str(antiqueens_merit,'%1.2f') ...
	     '; params = ' num2str(antiqueens_params,'%2.1f ') '\n']);
    antiqueens_params = current_params(antiqueens_num,:);
    antiqueen_changed = 1;
  else
    antiqueen_changed = 0;
  end
  
  if queen_changed ==0 &  antiqueen_changed ==0
    num_static_its = num_static_its + 1;
  else
    num_static_its = 0;
  end
  
  
  % calculate velocities
  
  if queens_merit >= (-0.75*antiqueens_merit)
    queens_params_big = repmat(queens_params,[num_particles,1]);
    fprintf('following queen\n');
  else
    queens_params_big = repmat(antiqueens_params,[num_particles, ...
		    1]);
    fprintf('following antiqueen\n');
  end
  
  velocity = velocity + ...
             c1*rand(size(velocity)).*(my_best_params-current_params) + ...
             c2*rand(size(velocity)).*(queens_params_big-current_params);
  velsgn   = sign(velocity);
  velabs   = abs(velocity);
  velocity = velsgn .* min(velabs,vmaxb);

  % move particles
  current_params = current_params + velocity;
  
  % wrap wrap-able params
  %if 0
  for ii = 1:length(xl)
    if xw(ii)
      tmp = current_params(:,ii);
      toobig = find(tmp>xu(ii));
      tmp(toobig) = tmp(toobig) - xu(ii) + xl(ii);
      toosmall = find(tmp<xl(ii));
      tmp(toosmall) = tmp(toosmall) - xl(ii) + xl(ii);
      current_params(:,ii) = tmp;
    end
  end
  %end
  
  % floor or ceiling other params
  current_params = min(current_params,xub);
  current_params = max(current_params,xlb);

  % diagnostic display
  figure(2);
  d = xu-xl;
  showdims = find(d>0);
  xl_big = repmat(xl,size(current_params,1),1);
  xu_big = repmat(xu,size(current_params,1),1);
  num = 2*floor(length(showdims)/2);
  for ii = 1:2:num
    subplot(num/2,1,floor(ii/2)+1);
    dim1 = showdims(ii);
    dim2 = showdims(ii+1);
    cp = current_params(:,[dim1, dim2]);
    plot(cp(:,1),cp(:,2), 'b.');
    hold on;
    plot(queens_params(dim1),queens_params(dim2),'g.');
    plot(antiqueens_params(dim1),antiqueens_params(dim2),'r.');
    axis([xl(dim1) xu(dim1) xl(dim2) xu(dim2)]);
    xlabel(num2str(dim1));
    ylabel(num2str(dim2));
    hold off;
  end
  drawnow;
  
end

end

fstar = -queens_merit;
xstar = queens_params;

state = 1;


