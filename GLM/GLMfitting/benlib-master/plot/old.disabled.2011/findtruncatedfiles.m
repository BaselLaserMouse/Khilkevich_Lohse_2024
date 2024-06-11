
sql=['select sCellFile.path, sCellFile.respfile from sCellFile' ...
     ' left join gCellMaster on sCellFile.masterid=gCellMaster.id' ...
     ' where sCellFile.runclassid in ("2","12") and gCellMaster.area="v2"' ...
     ' order by gCellMaster.cellid'];

dbopen;
result = mysql(sql);

for ii = 1:length(result)
  %fprintf([result(ii).respfile '\n']);
  r = respload([result(ii).path result(ii).respfile],'r');
  gotdata = sum(isfinite(r'))>0;
  
  f = find(~gotdata);

  if length(f)>2 & ~isempty(find(f==length(r)))
    % then there are some missing, including the last frame
    d = diff(f);

    nonconsecutive=find(d>1);
    if length(nonconsecutive)==0
      firstconsec=f(1);
      fprintf([result(ii).respfile ': Data end at ' num2str(firstconsec) '\n']);
    elseif length(nonconsecutive>0) & ((nonconsecutive(end)+1) < length(f))
      firstconsec = f(nonconsecutive(end)+1);
      fprintf([result(ii).respfile ': Data end at ' num2str(firstconsec) '\n']);
    end
    
  end
end
