function files = getdirsmatching(pattern)
% get files matching a unix pattern

list = ls('-d', pattern);
files = strsplit(list,'\n');

notempty = cellfun(@(x) length(x)>0, files);
files = files(notempty);

files = sort(files)';
