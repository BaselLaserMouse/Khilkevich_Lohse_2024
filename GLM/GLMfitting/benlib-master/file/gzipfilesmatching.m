function gzipfilesmatching(pattern)

filenames = getfilesmatching(pattern);

if isempty(filenames)
  return;
end

for ii = 1:length(filenames)
  file = filenames{ii};
  gzip(file);
  delete(file);
end