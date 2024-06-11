l = jls('*.imsm');

for ii = 1:length(l);
  [framecount, iconside] = imfileinfo(l{ii});
  fprintf([l{ii} ' ' num2str(framecount) ' ' num2str(iconside(1)) ' '  num2str(iconside(2)) '\n']);
  if (round(framecount/1000) ~= framecount/1000) | ~strfind(l{ii},iconside(1))
    keyboard;
  end
  
end
