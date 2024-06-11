function [fstar, xstar, state] = temper(costfunc,modelfunc,...
					xl,xu,xw,xi,...
					fitdata, optparams)

warning 'off' 'MATLAB:divideByZero'

cost = makeegabor(32, 17, 17, 12, 1, -pi/2, 0, 8);
cost = cost-min(cost(:))+rand(size(cost))*.3;

if ~exist('optparams')
  num_particles = 10;
  scale = .01;
  swapevery = 10;
  maxstaticits = 10;
else
  num_particles = optparams(1);
  scale         = optparams(2);
  swapevery     = optparams(3);
  maxstaticits  = optparams(4);
end

% upper and lower bounds in vectorised form
xlb = repmat(xl,[num_particles,1]);
xub = repmat(xu,[num_particles,1]);

% inital positions are randomly chosen...
current_params = zeros(num_particles,length(xl));
for ii = 1:num_particles
  current_params(ii,:) = rand(size(xl)).*(xu-xl)+xl;
end

% ... unless xi is specified, in which case we make 
% one particle start at the point specified by xi
% NB this is the most conservative particle. does it matter?
if length(xi)>0
  current_params(1,:) = xi;
end

% particle temperatures; 1 is the lowest
my_temp = [logspace(-3,3,num_particles)];

% er...
fitdata.newfit = 1;
  
% how many iterations have we been through without any improvement?
num_static_its = 0;

% best-ever
best_ever_cost = 1e100;
best_ever_params = zeros(1,size(current_params,2))+nan;

% get costs of initial positions
for ii = 1:num_particles
  %current_cost(ii) = cost(floor(current_params(ii,1)),floor(current_params(ii,2)));
end

while num_static_its < max_static_its
  for count = 1:swapevery
    for ii = 1:num_particles

      % move particle randomly
      new_params = current_params(ii,:) + (rand(size(xub(ii,:)))-.5).*(xub(ii,:)-xlb(ii,:))*scale;
      new_params = min(new_params,xub(ii,:));
      new_params = max(new_params,xlb(ii,:));
      
      % calculate new cost
      %new_cost = cost(floor(new_params(1)), floor(new_params(2)));
            
      % cost change
      dcost = new_cost - current_cost(ii);
      
      if dcost<0
	% cost improved (got lower), so accept
	p_move = 1;
      else
	% cost got worse; calculate P(accept)
	p_move = exp(-1/(imp*my_temp(ii)));
	if ~isfinite(p_move)
	  p_move = 0;
	end
      end
            
      if rand<=p_move
	% decide whether to move
	current_params(ii,:) = new_params;
	current_cost(ii) = new_cost;
      end
      if current_cost(ii) < best_ever_cost
	best_ever_cost = current_cost(ii);
	best_ever_params = current_params(ii,:);
      end
      
    end % for ii = 1:numparticles

  end % for count = 1:swapevery

  % every so often, swap positions of neighbouring particles, if
  % appropriate
  for ii = 1:num_particles-1
    dcost = current_cost(ii+1)-current_cost(ii);
    tempdiff = (1/my_temp(ii) - 1/my_temp(ii+1));
    
    p_swap = exp(-dcost*tempdiff);
    if ~isfinite(p_swap)
      p_swap = 0;
    end
    
    if rand <= p_swap
      tmp = current_params(ii,:);
      current_params(ii,:) = current_params(ii+1,:);
      current_params(ii+1,:) = tmp;
    end
  
  end % for ii = 1:num_particles-1

end % while 

warning 'on' 'MATLAB:divideByZero'