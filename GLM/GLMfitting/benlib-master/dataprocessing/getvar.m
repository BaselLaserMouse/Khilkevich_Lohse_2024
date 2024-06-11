function result = getvar(filename, varname)
% function result = getvar(filename, varname)
% 
% Load the specified file and return the specified variable.
% Useful

load(filename);

result = eval(varname);