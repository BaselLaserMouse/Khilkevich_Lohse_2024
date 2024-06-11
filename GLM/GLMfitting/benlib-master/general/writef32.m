function writef32(data, filename)
error('obsolete -- use f32write instead');

f = fopen(filename,'w');
if (f==-1)
  disp('Could not open file');
  data = nan;
  return
else
  fwrite(f, data, 'float32');
  fclose(f);
end
