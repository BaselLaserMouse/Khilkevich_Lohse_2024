function structmemory(s)
  
  % only look at first element of array; then multiply up
  mult = length(s);
  s = s(1);
  
  names = fieldnames(s);
  for name = 1:length(names)
    tst = getfield(s, names{name});
    stats = whos('tst');
    bytes = stats.bytes*mult;
    if bytes>=1024^3
      size_str = sprintf('%0.2f GB', bytes/(1024^3));
    elseif bytes>=1024^2
      size_str = sprintf('%0.2f MB', bytes/(1024^2));
    else
      size_str = sprintf('%d Bytes', bytes);
    end
    fprintf('%25s:  %s\n', names{name}, size_str);
  end