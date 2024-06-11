function result = lsbw2(pattern,ignoredotfiles)
% function result = lsbw2(pattern,ignoredotfiles)
% BW March 2008
% 
% List files matching dirname or pattern and
% return a cell array
% A surprising amount is required here because
% (a) matlab's dir() returns a struct
% (b) it only returns the leafname
% Here, we process stuff so it returns the complete path
% in the format originally given

if ~exist('ignoredotfiles','var')
  ignoredotfiles = 1;
end

% first, list the directory and get a cell array using deal()
dirStruct = dir(pattern);
result = cell(length(dirStruct),1);
[result{:}] = deal(dirStruct.name);

if ignoredotfiles
  f = find( (~strcmp('.',result)) & (~strcmp('..',result)) );
  result = result(f);
end

% we want to return the whole pathname, so we need to work out what prefix
% to add to the leafname that matlab's dir() has given us
if exist(pattern,'dir')
  % then we're going to receive the contents of the directory from dir()
  prefix = pattern;
  if prefix(end)~='/'
    prefix(end+1) = '/';
  end

else
  % then we're matching a pattern within a directory
  % so we need the directory name
  f = find(pattern=='/');
  if isempty(f)
    prefix = '';
  else
    prefix = pattern(1:f(end));
  end
  
end

prefix = {prefix};
prefix = repmat(prefix,size(result));
result = cellfun(@strcat,prefix,result,'UniformOutput',false);

