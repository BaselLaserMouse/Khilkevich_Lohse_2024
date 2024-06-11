function gzipdata(dirname)

dirnames = getdirsmatching([dirname filesep 'P*']);

for ii = 1:length(dirnames)
  dir = dirnames{ii};
  fprintf([dir '\n']);
  try
 	getfilesmatching([dir filesep 'raw.f32/*.f32']);
  catch
	continue;
  end
  gzipfilesmatching([dir filesep 'raw.f32/*.f32']);
end