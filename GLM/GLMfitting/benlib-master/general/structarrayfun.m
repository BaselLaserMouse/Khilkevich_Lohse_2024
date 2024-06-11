function y = structarrayfun(fun,s)
%function y = structarrayfun(fun,s)
% Evaluates function fun on all the fields of the struct array s
% and returns a struct array with the resulting values assigned to the fields.
%
% For example: uniqueparams = structarrayfun(@(x) unique(x)), stimparams)
% returns the unique values from all fields.

y = struct();
fn = fieldnames(s);
for ii = 1:length(fn)
  d = reach(s,fn{ii});
  y = setfield(y,fn{ii},feval(fun,d));
end
