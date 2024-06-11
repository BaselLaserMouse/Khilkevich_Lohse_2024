function data = getfilesmatching(searchstring, condition)

if ispc
  searchstring = strrep(searchstring,'/','\');  % convert "/" filesep into ugly "\"
end

if exist('condition', 'var')
  temp = rdir(searchstring, condition); % thanks Thomas Vanaret for http://www.mathworks.com/matlabcentral/fileexchange/32226-recursive-directory-listing-enhanced-rdir
else
  temp = rdir(searchstring);
end

data = {temp.name}';

if ispc
  data = cellfun(@(x) strrep(x,'\\','/'), data, 'uni', false); % convert ugly "\\" back to much less troublesome "/" filesep
  data = cellfun(@(x) strrep(x,'\','/'), data, 'uni', false); % convert ugly "\" back to much less troublesome "/" filesep
end
