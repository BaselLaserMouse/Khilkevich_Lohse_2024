function [mn,sd,raster] = dbgetresp(in)

stats = [];

if exist(in,'file')
  r = respload(in,'r');
  fnd = findstr(in,'/');
  if isempty(fnd)
    fnd = 0;
  end
  nm = in(fnd(end)+1:end);
else
  params = getnrparams(in);
  params.resploadparms = {'r',1,1,0};
  r = xcloadresp(params.times(3).fileidx,params.times(3).start, ...
		 params.times(3).stop,params);
  nm = in;
end

raster = r;

mn = nanmean(r');
sd = nanstd(r');