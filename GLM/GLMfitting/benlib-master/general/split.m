function bits = split(str, del)

  f = find(str==del);

  if ~any(f==1)
    f = [0 f];
  end
  
  if ~any(f==length(str))
    f = [f length(str)+1];
  end
  
  bits = {};
  for ii = 1:length(f)-1
    bits{ii} = str(f(ii)+1:f(ii+1)-1);
  end