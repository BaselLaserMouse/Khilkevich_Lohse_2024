animal = 'eddie';
%includewells = '("1","2","3","4","6","7")';
includewells = '("7")';

%animal = 'ziggy';
%includewells = '("5","6")';

%animal = 'reese';
%includewells = '("16","17")';

% gr=1; nr=2; opti=12; wg=5
RUNCLASSIDS = '("1","2","12","5")';

rejectcells='("R240A","R247B","model","models")';

sql=['SELECT gSingleRaw.rawid, gDataRaw.cellid,', ...
     ' gDataRaw.stimpath, gDataRaw.stimfile,' ...
     ' gDataRaw.resppath, gDataRaw.respfile,', ...
     ' gDataRaw.runclassid, gDataRaw.stimspeedid ', ...
     ' FROM gSingleRaw',...
     ' LEFT JOIN gSingleCell ON gSingleRaw.singleid=gSingleCell.id',...
     ' LEFT JOIN gDataRaw ON gSingleRaw.rawid=gDataRaw.id',...
     ' LEFT JOIN gCellMaster ON gSingleCell.masterid=gCellMaster.id',...
     ' WHERE gDataRaw.runclassid in',RUNCLASSIDS,...
     ' AND gCellMaster.animal="', animal, '"'...
     ' AND gCellMaster.well in ',includewells,...
     ' AND gDataRaw.bad=0',...
     ' AND gSingleCell.crap=0',...
     ' AND gSingleRaw.crap=0',...
     ' AND not(gDataRaw.cellid in ',rejectcells,')',...
     ' ORDER BY gDataRaw.id,gSingleRaw.id'];

dbopen;
result = mysql(sql);

for ii = 1:length(result)
  r = result(ii);
  %fprintf([num2str(r.rawid) ' ' r.cellid '\n']);
  resproot = [r.resppath r.respfile];
  if exist([resproot '.mat'],'file')
    m = load([r.resppath r.respfile '.mat']);
    goon = 1;
  elseif exist([resproot '.p1.mat'],'file')
    m = load([r.resppath r.respfile '.p1.mat']);
    goon = 1;
  else
    fprintf([r.cellid ' ' num2str(r.rawid) ': response file doesnt exist!!\n']);
    goon = 0;
  end
  
  if goon==1
    % check (the end of the) pathname is right
    s = strsplit(m.fpath,'/');
    actual_stimpath = [s{end-1} '/' s{end} '/'];
    s = strsplit(r.stimpath,'/');
    db_stimpath = [s{end-1} '/' s{end} '/'];
    if ~strcmp(db_stimpath,actual_stimpath)
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' actual_stimpath ' ' db_stimpath '\n']);
    end
    
    % check leafname is right
    if isfield(m.h,'indexfile')
      indexfile = m.h.indexfile;
    else
      indexfile = m.h.index;
    end
    
    if ~strcmp(indexfile,r.stimfile)
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' indexfile ' ' r.stimfile '\n']);
    end
    
    % check the stimulus class is (roughly) right
    rcid = r.runclassid;
    if rcid==1 & isempty(findstr(r.stimpath,'grat'))
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' num2str(rcid) ' ' actual_stimpath '\n']);
    end
    if rcid==2 & isempty(findstr(r.stimpath,'nat'))
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' num2str(rcid) ' ' actual_stimpath '\n']);
    end
    if rcid==12 & isempty(findstr(r.stimpath,'opt'))
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' num2str(rcid) ' ' actual_stimpath '\n']);
    end
    if rcid==5 & isempty(findstr(r.stimpath,'wg'))
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' num2str(rcid) ' ' actual_stimpath '\n']);
    end
    
    % check the speed is right
    speedname = num2str(r.stimspeedid);
    if isempty(findstr(indexfile,speedname))
      fprintf([r.cellid ' ' num2str(r.rawid) ': ' indexfile ' ' speedname '\n']);
    end
  end
  %fprintf([num2str(result(ii).rawid) ' ' result(ii).stimpath '\n']);
end
