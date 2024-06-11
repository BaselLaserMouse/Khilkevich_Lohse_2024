hex = '';

for jj = 1:4
  len = 32;
  bin = rand(1,len)>=0.5

  binstr = '';
  for ii = 1:len
    if bin(ii) == 1
      binstr = [binstr '1'];
    else
      binstr = [binstr '0'];
    end
  end
  binstr

  dec = bin2dec(binstr)
  hex = [hex dec2hex(dec)]
end
