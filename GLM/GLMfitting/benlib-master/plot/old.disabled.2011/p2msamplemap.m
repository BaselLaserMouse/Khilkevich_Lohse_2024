function rfinfo = p2msamplemap(pf, params, save)
%function p2mSpotmap(pf)
%
%  apr 28 2003 bw
%  nasty hack of (bw modified) p2mspotmap to show which parts of space 
%  have been sampled.
%  instead of outputting the 50% contour as a series of points in 
%  rfinfo.x and rfinfo.y, it outputs the edges of the sampled square 
%  as a series of 4 points. silly really.
%
%  INPUT
%    pf = p2m datastructure
%
%  OUTPUT
%    ...None..
%
%Wed Mar 26 18:50:11 2003 mazer 

if ~exist('save', 'var');
  save = 0;
end

% Start with reasonable defaults for the options:
opts.start = 0;
opts.stop = 250;
opts.binsize = 32;
opts.tstep = 16;
opts.color = 0;
opts.contour = 1;
opts.smooth = 1;

% Now merge in the options supplied by the user in 'params'
if exist('params', 'var')
  if ~isempty(params)
    fn = fieldnames(params);
    for n = 1:length(fn)
      opts = setfield(opts, fn{n}, getfield(params, fn{n}));
    end
  end
end
opts

nrec = length(pf.rec);
ppd = p2mGetPPD(pf, 1);

S = [];
for recno=1:nrec
  [ix_on,ts_on]=p2mFindEvents(pf, recno, 'spot on');
  for n=1:length(ix_on)
    k = 1+size(S,1);
    ev = strsplit(pf.rec(recno).ev_e{ix_on(n)}, ' ');
    S(k, 1) = str2num(ev{3});
    S(k, 2) = str2num(ev{4});
    S(k, 3) = str2num(ev{5});
  end
end
S = unique(S, 'rows');

T = (opts.start-opts.binsize):1:(opts.stop+opts.binsize);
K = zeros([size(S, 1) size(T,2)]);
Kn = zeros([size(S, 1) size(T,2)]);

for recno=1:nrec
  fprintf('.');
  [ix_on,ts_on]=p2mFindEvents(pf, recno, 'spot on');
  [ix_off,ts_off]=p2mFindEvents(pf, recno, 'spot off');

  for n=1:length(ix_off)
    ev = strsplit(pf.rec(recno).ev_e{ix_on(n)}, ' ');
    x = str2num(ev{3});
    y = str2num(ev{4});
    p = str2num(ev{5});
    row = find(S(:,1)==x & S(:,2)==y & S(:,3)==p);
    
    for k=1:length(pf.rec(recno).spike_times)
      % spike time relative to spot onset
      st = pf.rec(recno).spike_times(k) - ts_on(n);
      v = (T==st);
      K(row, v) = K(row, v) + 1;
    end
    Kn(row, :) = Kn(row, :) + 1;
  end
end
fprintf('\n');
Kn(Kn == 0) = NaN;
K = K ./ Kn;

t = sort([(-(opts.tstep):-(opts.tstep):opts.start) ...
	  0:(opts.tstep):opts.stop]);
k = zeros([size(S, 1) size(t,2)]);
for n=1:size(t,2)
  t1 = t(n) - (opts.binsize/2);
  t2 = t(n) + (opts.binsize/2);
  ix = find(T >= t1 & T < t2);
  k(:, n) = 1000.* mean(K(:,ix),2) / length(ix);
end

xg = unique(S(:,1));
yg = unique(S(:,2));
pg = unique(S(:,3));

rfinfo.x = [min(xg) min(xg) max(xg) max(xg)];
rfinfo.y = [min(yg) max(yg) max(yg) min(yg)];

rfinfo.x = rfinfo.x/ppd;
rfinfo.y = rfinfo.y/ppd;
