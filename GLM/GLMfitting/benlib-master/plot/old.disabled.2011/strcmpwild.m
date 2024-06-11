function success = strcmpwild(instr,wildstr)
% function success = strcmpwild(instr,wildstr)
%
% wildcard matching. if instr matches wildstr, where
% wildstr can contain * which matches any chars,
% return 1, otherwise 0

wildloc = find(wildstr=='*');

if isempty(wildloc)
  if strcmp(instr,wildstr)
     success = 1;
     return;
  else
     success = 0;
     return;
  end
end

if wildloc(1) ~= 1
  matchstr = wildstr(1:wildloc(1)-1);
  ln = length(matchstr);
  if length(instr)>=ln
    if strcmp(instr(1:ln),matchstr)
      instr = instr(ln+1:end);
      wildstr = wildstr(ln+1:end);
    else
      success = 0;
      return;
    end
  else
    success = 0;
    return;
  end
end

wildloc = find(wildstr=='*');
if wildloc(end) ~= length(wildstr)
  matchstr = wildstr(wildloc(end)+1:end);
  ln = length(matchstr);
  if length(instr)>=ln
    if strcmp(instr(end+1-ln:end),matchstr)
      instr = instr(1:end-ln);
      wildstr = wildstr(1:end-ln);
    else
      success = 0;
      return;
    end
  else
    success = 0;
    return;
  end
end

wildloc = find(wildstr=='*');
while length(wildloc) > 1
  matchstr = wildstr(2:wildloc(2)-1);
  f = findstr(instr,matchstr);
  if isempty(f)
    success = 0;
    return;
  else
    wildstr = wildstr(2+length(matchstr):end);
    instr   = instr(f+length(matchstr):end);
    wildloc = find(wildstr=='*');
  end
end

success = 1;
