function sm_make_srcs(directory)

% batch convert a load of directories from src to mat format
% (spikemonger stage 1)
% bw mar 2009

if ~exist('directory','var')
  directory = pwd;
end

directory = fixpath(directory);

subdirs = lsbw(directory);

for ii = 1:length(subdirs)
  try
    fprintf([directory subdirs{ii} '\n']);
    S1_convert_srcs([directory subdirs{ii}]);
  catch
    l = lasterror;
    fprintf([l.message '\n']);
  end
end
