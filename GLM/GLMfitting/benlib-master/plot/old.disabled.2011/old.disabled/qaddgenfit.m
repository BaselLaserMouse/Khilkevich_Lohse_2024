function qaddgenfit(analpat);
% apr 28 2003 willmore
% goes through the specified directory, interpreting the .anal. files 
% as sets of params to pass to cellxcnodb.  then makes queue entries
% correspondingly.  you can then run the queue using wrunqueue (to run
% on a single machine from matlab) or etohqueue (to run on a single
% machine outside matlab) or runqueue n (to run on n machines outside 
% matlab)

if ~exist('analpat','var')
  analpat = '.';
end

dirlist = jls(analpat);

for ii = 1:length(dirlist)
  fname = dirlist{ii};
  fname = cannonicalfname(fname);
  if ~isempty(findstr(fname,'.mat'))
    load(fname);
    if exist('anal','var')
      disp(['queueing ',fname]);
      progname = 'monkgenfit';
      cmdstr = ['load(''', fname, ''');monkgenfit(anal.params);'];
      if isfield(anal.params,'costfunc') & isfield(anal.params, ...
						  'cellid')
	notestr = [anal.params.cellid ' ' anal.params.costfunc];
      else
	notestr = 'genfit';
      end
      queueid = dbaddqueuemaster(cmdstr,notestr);
    end
  end
end

