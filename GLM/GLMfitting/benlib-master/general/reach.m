function result = reach(parent,daughter,use_a_cell)
    % REACH
    %   reach(parent,daughter)
    % where
    %   - parent is a struct
    %   - daughter is a string
    %
    % allows you to retrieve [parent(ii).daughter] when daughter is a
    % series of substructures.
    %
    % eg consider the structure
    %   animals.dog(1:10).woof.volume
    % matlab allows [animals.dog.woof], to give the 10 woofs, but not
    % [animals.dog.woof.volume].
    %
    % instead, type
    %   reach(animals.dog,'woof.volume')
    
%% error handling / input processing

% parse whether the output should be a cell
if nargin < 3
  use_a_cell = 0;
elseif nargin==3
  if ischar(use_a_cell)
    switch use_a_cell
      case {'y','yes','Y','Yes','YES','c','cell','C','Cell','CELL'}
        use_a_cell = 1;
      otherwise
        use_a_cell = 0;
    end
  end
end

% error handling
if ~isstruct(parent)
    error('input:error', 'first argument needs to be the structure itself');
end

if ~isa(daughter,'char')
    error('input:error', 'second argument needs to be a string');
end 

% remove any leading dots
if pick(daughter,1)=='.'
    daughter = daughter(2:end);
end


%% evaluate
% ===========

% define function
f = str2func(['@(x) x.' daughter]);

% evaluate it
if use_a_cell
  result = arrayfunc(f, parent);
else
  try
    result = arrayfun(f, parent);
  catch ME
    if isequal(ME.identifier, 'MATLAB:arrayfun:NotAScalarOutput')
      result = cell2mat(arrayfunc(f, parent));
    else
      rethrow(ME);
    end
  end
end

