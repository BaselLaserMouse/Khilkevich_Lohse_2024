function dorc(respfile,sz,whiflag,transform)

if ~exist('whiflag','var')
  whiflag = 0;
end

if ~exist('transform','var')
  transform = 'pfft';
end

if whiflag ==0
  fprintf('Normal natrev\n');
  imsmname = '/auto/fs2/willmore/matlab/stimuli/imsm/natrev2004.96.index60.1.pix16';
else
  % whitened nr
  fprintf('Whitened natrev\n');
  imsmname = '/auto/fs2/willmore/matlab/stimuli/imsm/wnatrev2004.96.index60.1.pix16';
end
fprintf([imsmname '\n']);

[y m d] = datevec(date);
datestr = [num2str(y) '-' sprintf('%-.2d',m) '-' sprintf('%-.2d',d)];
cellid = respfile(1:5);

outdir = ['/auto/sal1/stim/opti/e' datestr '/' cellid '/' transform];
fprintf(['Save to directory: ' outdir '\n']);

rconline(respfile,imsmname,sz,transform);
