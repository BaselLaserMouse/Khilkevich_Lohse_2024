function updatemetadatafile(filename, newmetadata)

if exist(filename, 'file')
  l = load(filename);
  metadata = l.metadata;
  %movefile(filename, [filename  '.old.mat']);
else
  metadata = struct;
end
  
fnames = fieldnames(newmetadata);

for fname = fnames'
  metadata = setfield(metadata, fname{1}, getfield(newmetadata, fname{1}));
end

fprintf('Saving as %s\n', filename');
save(filename, 'metadata');
