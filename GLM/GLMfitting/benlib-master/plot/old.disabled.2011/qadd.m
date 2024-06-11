function makequeuemaster(analpat);
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
%keyboard;

for ii = 1:length(dirlist)
  fname = dirlist{ii};
  fname = cannonicalfname(fname);
  if ~isempty(findstr(fname,'.mat'))
    load(fname);
    if exist('anal','var')
      disp(['queueing ',fname]);
      progname = 'cellxcnodb';
      param    = ['load(''', fname, ''');params=anal.params'];
%      queueid = dbaddqueue(anal.expt.masterid,'cellxcnodb(params)', ...
%			   param);
      cmdstr = ['load(''', fname, ''');cellxcnodb(anal.params);'];
      queueid = dbaddqueuemaster(cmdstr);
    end
  end
end

