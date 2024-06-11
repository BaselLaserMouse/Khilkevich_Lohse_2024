function bprintf(varargin)
% function bprintf(varargin)
% fprintf preceded by lab number, if in a parfor loop

t = getCurrentTask();                                                                                                                                 

if ~isempty(t)
  worker = t.ID;
  fprintf('=  Lab %d: ', worker);
end

fprintf(varargin{:});
