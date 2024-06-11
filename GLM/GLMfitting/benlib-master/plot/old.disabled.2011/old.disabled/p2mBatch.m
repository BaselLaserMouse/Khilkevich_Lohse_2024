function p2mBatch(wildcard, inplace, exitOnError, ignorep2ms)
%function p2mBatch(wildcard, inplace, exitOnError)
%
%  Batch engine for converting pype files into matlab loadable
%  datafiles.  Given a wildcard pattern of pype file names, this
%  does through them and automatically generates *.p2m files
%  for each datafile and saves to XXX.p2m
%
%  INPUT
%    wildcard = CSH-style wildcard pattern of files to crunch
%    inplace = Boolean (0/1) specifying where to put p2m files.
%		If true, then matlab (.p2m) files will be
%		written into the same directory the original
%		datafiles came from.
%    ignorep2ms = Boolean specifying (if 1) that files ending
%    '.p2m' should be ignored.
%
%  OUPUT
%    none -- just writes the datafiles to disk.
%
%Sun Feb 16 17:36:37 2003 mazer 
%
% Tue May 27 2003 willmore
% added ignorep2ms to stop it from reintepreting p2m files

if ~exist('inplace', 'var')
  inplace = 0;
end

if ~exist('exitOnError', 'var')
  exitOnError = 0;
end

if ~exist('ignorep2ms', 'var')
  ignorep2ms = 0;
end


files = p2m_dir(wildcard,ignorep2ms);
for n = 1:length(files)
  pypefile = char(files(n));
  
  if inplace
    matfile = [pypefile '.p2m'];
  else
    ix = find(pypefile == '/');
    if length(ix) > 0
      matfile = pypefile((ix(end)+1):end);
    else
      matfile = pypefile;
    end
    matfile = ['./' matfile '.p2m'];
  end
  matfile = strrep(matfile, '.gz', '');

  try
    fprintf('%s -> %s\n', pypefile, matfile);
    PF = p2m(pypefile);
    save(matfile, 'PF', '-mat');
    fprintf('Saved data to ''%s''\n', matfile);
  catch
    if exitOnError
      p2mExit(1);
    else
      error(lasterr);
    end
  end
end
