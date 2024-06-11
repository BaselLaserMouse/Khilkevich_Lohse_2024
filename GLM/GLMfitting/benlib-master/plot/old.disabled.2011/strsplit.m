function bits = strsplit(instr,delimiter)
% function bits = strsplit(instr,delimiter)
%
% split a string into sections at delimiter and
% return the bits in a cell array

if delimiter == '\n'
  delimiter = char(10);
end

instr = [instr delimiter];

bits = {};
bitcounter = 0;

while length(instr)>1 & (instr(1)==delimiter)
  instr = instr(2:end);
end

while length(instr)>1
  f = findstr(instr,delimiter);
  bitcounter = bitcounter + 1;
  bits{bitcounter} = instr(1:f(1)-1);
  instr = instr(f(1)+1:end);
  while length(instr)>1 & (instr(1)==delimiter)
    instr = instr(2:end);
  end

end
