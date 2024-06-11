function result = lsbw(pat)
% result = jls(pat)

dircell = dir(pat);
result = {};
for ii = 1:length(dircell)
  name = dircell(ii).name;
  if ~strcmp(name,'.') && ~strcmp(name,'..')
    result{end+1} = name;
  end
end


