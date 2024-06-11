kb = ['1' '2' '3' '4' '5' '6' '7' '8' '9' '0' '-' '=';
  'q' 'w' 'e' 'r' 't' 'y' 'u' 'i' 'o' 'p' '[' ']';
  'a' 's' 'd' 'f' 'g' 'h' 'j' 'k' 'l' ';' '''' '\';
  'z' 'x' 'c' 'v' 'b' 'n' 'm' ',' '.' '/' ' ' ' '];

a = input('PW: ','s');


for xoff = -2:2
  for yoff = -2:2

    b = '';
    failed = 0;

    for ii = 1:length(a)
      [y,x] = find(kb==a(ii));
      y = y-yoff;
      x = x+xoff;
      if ( y<1 || y>size(kb,1) || x<1 || x>size(kb,2) )
        failed = 1;
        b = '';
      else
      b(end+1) = kb(y,x);
      end
    end

    if ~failed
      fprintf(['x=' num2str(xoff,'%3d')  ' y=' num2str(yoff,'%3d') ': ' b '\n']);
    end
    
  end
end