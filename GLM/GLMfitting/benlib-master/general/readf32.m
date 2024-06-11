function data = readf32(filename)
error('obsolete -- use f32read instead');

f = fopen(filename,'r');
if (f==-1)
  disp('Could not open file');
  data = nan;
  return
else
  data = fread(f,Inf,'float32');
  fclose(f);
end
