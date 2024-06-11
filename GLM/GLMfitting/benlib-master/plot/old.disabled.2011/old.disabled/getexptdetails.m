sql_start = ['select sCellFile.id, sCellFile.cellid, gDataRaw.runclass,' ...
	     ' sCellFile.stimpath, sCellFile.stimfile, sCellFile.path,' ...
	     ' sCellFile.respfile' ...
	     ' from sCellFile left join gDataRaw' ...
	     ' on sCellFile.rawid=gDataRaw.id' ...
	     ' left join gCellMaster' ...
	     ' on gDataRaw.masterid=gCellMaster.id' ...
	     ' where sCellFile.addedby="willmore"' ...
	     ' and gCellMaster.area="'];

sql_middle = ['" and gDataRaw.runclassid='];

sql_middle2= [' and sCellFile.stimspeedid="'];

sql_end    = '" order by gDataRaw.cellid, gDataRaw.id;';

dbopen;

areas = {'V2';'V4'};
speeds = {'60';'30';'15';'7.5'};

print_to_file = 1;
if print_to_file
  h = fopen('~/expt_summary.txt','w');
else % print to screen
  h = 1;
end

for area_num = 1:length(areas)
  for runclassid=0:20
    for speed_num = 1:length(speeds)
      sql = [sql_start areas{area_num} sql_middle num2str(runclassid) ...
	     sql_middle2 speeds{speed_num} sql_end];
      result = mysql(sql);
      
      if length(result)>0
	fprintf(h,['Area ' areas{area_num} '; ' ...
		 result(1).runclass ' (' num2str(runclassid) '); ' ...
		 speeds{speed_num} 'Hz' ...
		 '\n']);
	
	for expt=1:length(result)
	  path = result(expt).path(length('/auto/data/archive/'):end);
	  fprintf(h,[result(expt).cellid ' ' num2str(result(expt).id) ' ' ...
		   result(expt).stimfile ' ' ...
		   path result(expt).respfile '\n']);
	end
	fprintf(h,'\n');
	
      end
    end
  end
end

if print_to_file
  fclose(h);
end
