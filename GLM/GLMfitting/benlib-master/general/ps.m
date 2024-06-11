function pathSep = ps
  % pathSep = ps
  %
  % return correct path separator (/ for unix/mac, \ for windows)
  
  if isunix
    pathSep = '/';
  else
    pathSep = '\';
  end