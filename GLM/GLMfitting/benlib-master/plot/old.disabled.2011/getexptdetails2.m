sql = ['select sCellFile.id, sCellFile.cellid, gDataRaw.runclass,' ...
       ' sCellFile.stimpath, sCellFile.stimfile, sCellFile.path,' ...
       ' sCellFile.respfile, sCellFile.stimspeedid, gDataRaw.runclassid' ...
       ' from sCellFile left join gDataRaw' ...
       ' on sCellFile.rawid=gDataRaw.id' ... 
       ' left join gCellMaster' ...
       ' on gDataRaw.masterid=gCellMaster.id' ...
       ' where sCellFile.addedby="willmore"' ...
       ' and gCellMaster.area="V2"'];

%areas = {'V2';'V4'};
%speeds = {'60';'30';'15';'7.5'};

result = mysql(sql);

cellids = {};
for ii = 1:length(result)
  cellids{end+1} = result(ii).cellid;
end

cellids = unique(cellids);

exp_framecount = zeros(length(cellids),15);
conf_framecount= zeros(length(cellids),15);

for ii = 1:length(cellids)
  for jj = 1:length(result)
    if strcmp(result(jj).cellid,cellids{ii})
      [fc, reps,d1,d2,d3,spikes]=respfileinfo([result(jj).path,result(jj).respfile],'r');
      
      if reps <= 2
	exp_framecount(ii,result(jj).runclassid+1) = ...
	    exp_framecount(ii,result(jj).runclassid+1)+fc;
      else
	conf_framecount(ii,result(jj).runclassid+1) = ...
	    conf_framecount(ii,result(jj).runclassid+1)+fc;
      end
    end
  end  
end
