function qdel(startnum,endnum,user)
% apr 28 2003 willmore
% deletes entries from the queue, starting at startnum and ending at endnum
% guesses badly if you don't supply a starting parm

if nargin == 0
  startnum = 1;
  endnum   = 10000;
end

if nargin == 1
  endnum = startnum + 200;
end

% find my jobs and, if running, send kill command
for num = endnum:-1:startnum
  s = dbgetqueue(num);
  
  if length(s) > 0
    % then the job exists
    
    if strcmp(s.user,'willmore') & s.complete == -1
      % then it's mine and it's running, so we need to kill it

      fprintf('%5d is running -- attempting to kill it\n',num);
      dbkillqueue(num,2);
      
    elseif strcmp(s.user,'willmore') & s.complete ~= -1
      % then it's safe to delete it
      fprintf('Deleting %5d\n', num);
      dbdeletequeue(num);
    end
  end
  
end

for num = startnum:endnum
  s = dbgetqueue(num);
  
  if length(s) > 0
    % then the job exists
    
    if strcmp(s.user,'willmore')
      % then it's mine, so we want to delete it
      
      if s.complete~=-1
	safetodelete = 1;
	
      else
	fprintf('Waiting for %5d to die',num);
	count = 0;
	safetodelete = 0;
	while count<11 & ~safetodelete
	  fprintf('.');
	  pause(2);
	  count = count + 1;
	  s = dbgetqueue(num);
	  safetodelete = s.complete~=-1;
	end
	fprintf('\n');
      end
      
      if safetodelete
	fprintf('Deleting %5d\n', num);
	dbdeletequeue(num);
      else
	fprintf('Cant kill %5d -- not deleting it\n',num);
      end
      
    end
  end
end
