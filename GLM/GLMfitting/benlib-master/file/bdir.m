function res = bdir(path)
% list a directory, excluding '.' and '..'

res = dir(path);
res = res(cellfun(@(x) x(end)~='.', {res.name}));
