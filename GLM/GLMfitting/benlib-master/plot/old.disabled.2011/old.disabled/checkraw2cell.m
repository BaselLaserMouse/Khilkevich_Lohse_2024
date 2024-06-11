% function [cellfileids]=checkraw2cell(rawids,fmt)
%
% (if not already done) convert to pype files to matlab-readable
% format and translate entries from gDataRaw to sCellFile
%
% if the conversion has already been done, simply return the
% cellfileids corresponding to the rawids and fmt (default='pixel')
% specified.
%
% CREATED SVD 3/3/03  (ripped off dbraw2scellfile.m)
%
function [cellfileids]=checkraw2cell(rawids,fmt)

[s,w] = unix('whoami');
if strcmp(w,'mauro')
  fprintf('You bastard!\n');
else
  fprintf('This has been disabled\n');
end

return;

dbopen;

% bw apr 2004

reprocesspypefile=1;

for kk=1:3
  if kk==1
    animal = 'eddie';
    includewells = '("1","2","3","4")';
    RUNCLASSIDS = '("1","2","12","5","0","4","13","14")';
  elseif kk==2
    animal = 'ziggy';
    includewells = '("5","6")';
    RUNCLASSIDS = '("1","2","12","5","0","4","13","14")';
  elseif kk==3
    animal = 'reese';
    includewells = '("16","17")';
    RUNCLASSIDS = '("1","2","12","4","13","14")';
  end
  
  % gr=1; nr=2; opti=12; wg=5; review=0; wnat=4 ;mseq=13 ;oldopti=14; drift=15
  %RUNCLASSID=13

  
  stimpathdata.eddie{1}='/auto/data/archive/stimarchive/ED02/imsm/';
  stimpathdata.eddie{2}='/auto/data/archive/stimarchive/ED02/imsm/';
  stimpathdata.eddie{3}='/auto/data/archive/stimarchive/ED02/imsm/';
  stimpathdata.eddie{4}='/auto/data/archive/stimarchive/ED02/imsm/';
  
  stimpathdata.ziggy{5}='/auto/data/archive/stimarchive/ED02/imsm/';
  stimpathdata.ziggy{6}='/auto/data/archive/stimarchive/ED02/imsm/';
  
  stimpathdata.reese{13}='/auto/data/archive/stimarchive/REESE13/imsm/';
  stimpathdata.reese{14}='/auto/data/archive/stimarchive/REESE14/imsm/';
  stimpathdata.reese{15}='/auto/data/archive/stimarchive/REESE15/imsm/';
  stimpathdata.reese{16}='/auto/data/archive/stimarchive/REESE16/imsm/';    
  stimpathdata.reese{17}='/auto/data/archive/stimarchive/REESE17/imsm/';
  
  %stimpathdata.model{2}='/auto/data/archive/stimarchive/ED02/imsm/';
  
  % root of path to store processed data
  % ie, data goes to:  $resproot/$pen_id
  
  if strcmp(animal,'reese')
    resproot='/auto/data/archive/reese_data/';
  elseif strcmp(animal,'eddie')
    resproot='/auto/data/archive/ed_data/';
  elseif strcmp(animal,'ziggy')
    resproot='/auto/data/archive/zig_data/';
  else
    'which animal???'
    return;
  end
  
  %resproot='/auto/data/archive/model_data/';
  
  rcsetstrings;
  if ~exist('fmt','var'),
    fmt='pixel';
  end
  stimfmtcode=find(strcmp(stimfilefmtstr,fmt))-1;
  fprintf('stimfilefmt=%s (code=%d)\n',fmt,stimfmtcode);
  
  
  rejectcells='("R240A","R247B","model","models")';
  
  if ~exist('rawids'),
    GENERALUPDATE=1;
    
    % find all gSingleRaw entries that fit various criteria
    % (e.g. not bad) and make a list of their IDs for later processing
    sql=['SELECT gSingleRaw.id, gSingleRaw.rawid,'...
	 ' gDataRaw.cellid, gSingleRaw.singleid' ...
	 ' FROM gSingleRaw',...
	 ' LEFT JOIN gSingleCell ON gSingleRaw.singleid=gSingleCell.id',...
	 ' LEFT JOIN gDataRaw ON gSingleRaw.rawid=gDataRaw.id',...
	 ' LEFT JOIN gCellMaster ON gSingleCell.masterid=gCellMaster.id',...
	 ' WHERE gDataRaw.runclassid in ',num2str(RUNCLASSIDS),...
	 ' AND gCellMaster.animal="', animal, '"'...
	 ' AND gCellMaster.well in ',includewells,...
	 ' AND gDataRaw.bad=0',...
	 ' AND gSingleCell.crap=0',...
	 ' AND gSingleRaw.crap=0',...
	 ' AND not(gDataRaw.cellid in ',rejectcells,')',...
	 ' ORDER BY gDataRaw.id,gSingleRaw.id'];
    
    srids=mysql(sql);
  else
    GENERALUPDATE=0;
    srawid='(';
    for ii=1:length(rawids),
      srawid=[srawid,num2str(rawids(ii)),','];
    end
    srawid(end)=')';
    
    sql=['SELECT gSingleRaw.id, gSingleRaw.rawid,'...
	 ' gDataRaw.cellid, gSingleRaw.singleid' ...
	 ' FROM gSingleRaw',...
	 ' LEFT JOIN gSingleCell ON gSingleRaw.singleid=gSingleCell.id',...
	 ' LEFT JOIN gDataRaw ON gSingleRaw.rawid=gDataRaw.id',...
	 ' LEFT JOIN gCellMaster ON gSingleCell.masterid=gCellMaster.id',...
	 ' WHERE gDataRaw.id in ',srawid,...
	 ' AND gCellMaster.animal="', animal, '"'...
	 ' AND gDataRaw.bad=0',...
	 ' AND gSingleCell.crap=0',...
	 ' AND gSingleRaw.crap=0',...
	 ' AND not(gDataRaw.cellid in ',rejectcells,')',...
	 ' ORDER BY gDataRaw.id,gSingleRaw.id'];
    
    srids=mysql(sql);
  end
  
  cellfileids=[];
  
  for sridx = 1:length(srids)
      this_srid = srids(sridx).id;
      this_rawid= srids(sridx).rawid;
      this_singleid= srids(sridx).singleid;
      this_cellid= srids(sridx).cellid;
      
      fprintf('** singlerawid %d; rawid %d; siteid %s\n',this_srid,this_rawid, this_cellid);
      
      % pick out all information about this gSingleRaw entry
      sql=['SELECT * FROM gSingleRaw',...
	   ' LEFT JOIN gSingleCell ON gSingleRaw.singleid=gSingleCell.id',...
	   ' LEFT JOIN gDataRaw ON gSingleRaw.rawid=gDataRaw.id',...
	   ' LEFT JOIN gCellMaster ON gSingleCell.masterid=gCellMaster.id',...
	   ' LEFT JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
	   ' WHERE gSingleRaw.id=',num2str(this_srid)];
      
      celldata=mysql(sql);
      
      % is there already an sCellFile entry corresponding to this singlerawid?
      sql=['SELECT * FROM sCellFile',...
	   ' WHERE singlerawid=',num2str(this_srid),...
	   ' AND stimfilefmt="',fmt,'"'];
      cellfiledata=mysql(sql);
      
      [cellfiledata.path cellfiledata.respfile]
      
      % if so, don't make a new scellfile entry, but check that the
      % necessary files are present
      if length(cellfiledata)>0,
	fprintf('Has sCellFile entry stim=%s. Checking for files...\n',...
		cellfiledata.stimfile);
	cellfileids=[cellfileids;cellfiledata.id];
	
	if ~exist([cellfiledata.stimpath,cellfiledata.stimfile],'file'),
	  disp('stimfile not found!');
	  keyboard;
	end
	
	if ~exist([cellfiledata.path,cellfiledata.respfile],'file'),
	  disp(['respfile' cellfiledata.path cellfiledata.respfile ' not found!']);
	  keyboard;
      end
      
      updatespikeinfo(cellfiledata.id);
      
      if reprocesspypefile
	matfile=processpypedata([celldata.resppath,celldata.respfile],1,0,[],celldata.channel,celldata.unit);
      end
      
      elseif ~strcmp(celldata.info(1:4),'CELL'),
	fprintf('No sCellFile entry but SGI-aged. Skipping...\n');
	
	%elseif RUNCLASSID==1 & (strcmp(celldata.animal,'mac') | ...
	%			  (strcmp(celldata.animal,'reese') & this_rawid<758)),
	%  disp('skipping data because old gratrev');
	
      else
	% make a new sCellFile entry!
	
	% construct path for processed pype data
	resppath=[resproot,celldata.penname,'/'];
	
	if ~exist(resppath,'dir'),
	  unix(['mkdir ',resppath]);
	end
	
	% get response data into matlab format
	
	if strcmp(celldata.channel,'p')
	  % use pypefile spikes
	  fprintf('Processing pypefile...\n');
	  matfile=processpypedata([celldata.resppath,celldata.respfile],1,0,[],celldata.channel,celldata.unit);
	else
	  % use plexon spikes
	  fprintf('Processing pypefile and plexon spike data...\n');
	  
	  if isempty(celldata.plexonfile)
	    fprintf('Plexon filename in db entry is blank!\n');
	    keyboard;
	    
	  else
	    if isempty(findstr(celldata.plexonfile),'/')
	      plexonfile = [resppath,celldata.plexonfile];
	      
	    else
	      plexonfile = celldata.plexonfile;
	    end
	    
	    if ~exist(plexonfile,'file')
	      fprintf('Specified plexonfile doesn''t exist!!\n');
	      keyboard;
	    else
	      matfile=processpypedata([celldata.resppath,celldata.respfile],...
				      0,0,celldata.plexonfile, ...
				      celldata.channel,celldata.unit);
	    end
	  end
	end
	
	% figure out construction of pre-computed imsm file:
	stimbase=celldata.stimpath;
	indexfile=celldata.stimfile;
	
	% special case for opti
	if ~isempty(findstr(stimbase,'opti'))
	  % we need to:
	  %   set stimpath = the path where the new imsm is
	  %   set stimfile = the new imsm filename
	  %   make an imsm
	  fnd = findstr(stimbase,'opti');
	  stimpath = [stimbase(1:fnd-1) 'imsm/']
	  stimfile = [stimbase(fnd:end)];
	  stimfile(find(stimfile=='/'))='.';
	  
	  if ~isempty(findstr(stimbase,'optichosen'))
	    % then it's optichoose (ED04), and we need the index file name
	    % in the imsm name to disambiguate index1, index2...
	    stimfile = [stimfile indexfile '.' fmt '.imsm'];
	  else
	    % it's opti (ED01/02/03)
	    stimfile = [stimfile fmt '.imsm'];
	  end
	  
	  % check whether imsm exists already
	  if ~exist([stimpath stimfile],'file')
	    fprintf('creating full pix imsm: %s%s\n',...
		    stimpath,stimfile);
	    [framecount,iconside]=pypestim2imsmraw(celldata.stimpath,celldata.stimfile,...
						   [stimpath,stimfile], ...
						   1);
	  else
	    [framecount,iconside]=imfileinfo([stimpath,stimfile]);
	  end
	  
	elseif ~isempty(findstr(stimbase,'wg20042'))
	  % we need to:
	  %   set stimpath = the path where the new imsm is
	  %   set stimfile = the new imsm filename
	  %   make an imsm
	  fnd = findstr(stimbase,'wg20042');
	  stimpath = [stimbase(1:fnd-1) 'imsm/']
	  stimfile = [stimbase(fnd:end)];
	  stimfile(find(stimfile=='/'))='.';
	  stimfile = [stimfile indexfile '.' fmt '.imsm'];
	  
	  if exist([stimpath stimfile],'file')
	    [framecount,iconside]=imfileinfo([stimpath,stimfile]);
	    fprintf('wg2 imsm already exists, skipping...');
	  else
	    fprintf('creating full pix imsm: %s%s\n',...
		    stimpath,stimfile);
	    [framecount,iconside]=pypestim2imsmraw(celldata.stimpath,celldata.stimfile,...
						   [stimpath, stimfile],1);
	  end
	  
	else
	  
	  if stimbase(end)=='/',
	    stimbase=stimbase(1:(end-1));
	  end
	  ii=max(findstr(stimbase,'/'));
	  jj=max([0 findstr(stimbase(1:ii-1),'/')]);
	  ostimbase=stimbase((jj+1):end);
	  
	  % for new natrev naming scheme where dir is only size
	  if ~isnan(str2double(stimbase((ii+1):end)))
	    stimbase(ii)='-';
	    ii=max(findstr(stimbase,'/'));
	  end
	  stimbase=[stimbase((ii+1):end),'.',celldata.stimfile,'.'];
	  
	  stimfile=[stimbase,fmt,'.imsm'];
	  
	  stimpathidx=celldata.well;
	  stimpathlist=getfield(stimpathdata,celldata.animal);
	  
	  if stimpathidx<=length(stimpathlist),
	    stimpath=stimpathlist{stimpathidx};
	  else
	    fprintf('stimpath not found for %s!\n',stimfile{1});
	    input('enter path: ',stimfile);
	  end
	  
	  
	  % figure out location of pgms
	  
	  if ~exist([stimpath,stimfile],'file'),
	    ii=findstr(stimpath,'imsm/');
	    indexpath=[stimpath(1:ii-1),ostimbase,'/' ];
	    indexfn=celldata.stimfile;
	    fprintf('creating full pix imsm: %s%s\n',...
		    stimpath,stimfile);
	    [framecount,iconside]=pypestim2imsmraw(indexpath,indexfn,...
						   [stimpath,stimfile],1);
	  else
	    [framecount,iconside]=imfileinfo([stimpath,stimfile]);   
	  end
	end
	
	
	% this following thing SHOULD work, but above hack is passable
	stimwindowsize=iconside(1);
	stimiconside=sprintf('%d,%d',iconside);
	
	z=load(matfile);
	resplen=sum(~isnan(z.psth(:,1)));
	respvarname='psth';
	respfmtcode=0;
	respfilefmt='PSTH'; % rather than PFTH
	[respfile,path]=basename(matfile);
	stimspeedid=celldata.stimspeedid;
	
	[aff,celldata.cellfileid]=...
	    sqlinsert('sCellFile',...
		      'cellid',celldata.cellid,...
		      'masterid',celldata.masterid,...
		      'rawid',this_rawid,...
		      'singleid',this_singleid,...
		      'singlerawid',this_srid,...
		      'runclassid',celldata.runclassid,...
		      'path',path,...
		      'resplen',resplen,...
		      'respfile',respfile,...
		      'respvarname',respvarname,...
		      'respfiletype',1,...
		      'respfilefmt',respfilefmt,...
		      'respfmtcode',respfmtcode,...
		      'stimfile',stimfile,...
		      'stimpath',stimpath,...
		      'stimwindowsize',stimwindowsize,...
		      'stimfilefmt',fmt,...
		      'stimfmtcode',stimfmtcode,...
		      'stimspeedid',stimspeedid,...
		      'stimiconside',stimiconside,...
		      'addedby','willmore',...
		      'info','checkraw2cell.m');
	cellfileids=[cellfileids;celldata.cellfileid];
	updatespikeinfo(celldata.cellfileid);


      end
  end
end
