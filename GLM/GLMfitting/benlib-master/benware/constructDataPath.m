function path = constructDataPath(pathTemplate, grid, expt, sweepNum, channelNum)
% path = constructDataPath(pathTemplate, grid, expt, sweepNum, channelNum)
%
% Replaces % tokens in a data filename with appropriate values. The tokens are:
%
% pathTemplate: pathname containing % tokens
% grid, expt: standard benWare data structures
% sweepNum: the sweep number
% 
% The % tokens (for data paths) are:
% %E = expt number, e.g. '29'
% %1, %2... %9 = stimulus parameter value
% %N = grid name
% %L = left or right (for stimulus file)
% %P = penetration number
% %S = sweep number
% %C = channel number

path = regexprep(pathTemplate, '%E', n2s(expt.exptNum));
path = regexprep(path, '%P', ['P' n2s(expt.penetrationNum, 2)]);

if ~isempty(grid)
  if isempty(grid.saveName)
      path = regexprep(path, '%N', grid.name);
  else
      path = regexprep(path, '%N', grid.saveName);
  end
end

if exist('sweepNum', 'var')
    path = regexprep(path, '%S', n2s(sweepNum));
end

if exist('channelNum', 'var')
    path = regexprep(path, '%C', n2s(channelNum, 2));
end
