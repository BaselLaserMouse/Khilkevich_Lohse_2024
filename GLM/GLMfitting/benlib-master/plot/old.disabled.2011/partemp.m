%function [fstar, xstar, state] = partemp(costfunc,modelfunc,...
%					     xl,xu,xw,xi,...
%					     fitdata, optparams)

warning 'off' 'MATLAB:divideByZero'

xl = [1 1];
xu = [32 32];
xw = [0 0];
xi = [];
scale = 1/6;

cost = makeegabor(32, 17, 17, 12, 1, -pi/2, 0, 8);
cost = cost-min(cost(:))+rand(size(cost))*.3;

if ~exist('optparams')
  num_particles = 10;
else
  num_particles = optparams(1);
end

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

% particle temperatures; particle 1 is the queen
my_temp = [logspace(-3,3,num_particles)];

fitdata.newfit = 1;

% iteration counter
iter = 0;

% function evaluation counter
num_func_evals = 0;
  
% how many iterations have we been through without any improvement?
num_static_its = 0;

for ii = 1:num_particles
  current_cost(ii) = cost(floor(current_params(ii,1)),floor(current_params(ii,2)));
end

[my mx] = find(cost==min(cost(:)));

while 1
  for count = 1:10
    imagesc(cost);colormap(gray);
    hold on;
    
    for ii = 1:num_particles
      % move particle randomly
      new_params = current_params(ii,:) + (rand(size(xub(ii,:)))-.5).*(xub(ii,:)-xlb(ii,:))*scale;
      new_params = min(new_params,xub(ii,:));
      new_params = max(new_params,xlb(ii,:));
      
      % calculate new merit
      new_cost = cost(floor(new_params(1)), floor(new_params(2)));
            
      imp = new_cost - current_cost(ii);
      
      if imp<0
	p_move = 1;
      else
	p_move = exp(-1/(imp*my_temp(ii)));
	if ~isfinite(p_move)
	  p_move = 0;
	end
	
      end
      
      %[ii current_cost(ii) new_cost p_move]
      
      if rand<=p_move
	current_params(ii,:) = new_params;
	current_cost(ii) = new_cost;
      end

      if ii==1
	plot(current_params(ii,2)-.5,current_params(ii,1)-.5,'g.');
      else
	plot(current_params(ii,2)-.5,current_params(ii,1)-.5,'r.');
      end
      
      %pause;
      
    end
    plot(mx,my,'b.');
    drawnow;
    hold off;

  end
  
  for ii = 1:num_particles-1
    imp = current_cost(ii+1)-current_cost(ii);
    tempdiff = (1/my_temp(ii) - 1/my_temp(ii+1));
    
    p_swap = exp(-imp*tempdiff);
    if ~isfinite(p_swap)
      p_swap = 0;
    end
    
    if rand <= p_swap
      tmp = current_params(ii,:);
      current_params(ii,:) = current_params(ii+1,:);
      current_params(ii+1,:) = tmp;
      
      if ii==1
	['swapped ' num2str(ii)]
      end
    end
  end

end


