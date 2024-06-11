% function [h,flist]=readindexfile(fn)
function [h,flist]=readindexfile(fn)

fprintf('reading index file: %s\n',fn);

h=[];
flist={};

fid=fopen(fn,'rb');
if fid==-1,
   disp('gethead.m: Error. File not found.');
   return
end
buffer=fread(fid,inf,'char');
fclose(fid);

eolidx=find(buffer==10);
lasteolidx=0;
frcount=0;
totfr=length(eolidx);
flist={};
for ii=1:length(eolidx),
   curline=char(buffer((lasteolidx+1):(eolidx(ii)-1))');

   pctidx=min(find(curline=='#' | curline=='%'));
   if ~isempty(pctidx),
      hline=curline(pctidx+1:end);
      
      chridx=min(find(hline~=' ' & hline~=9));
      whtidx=min([find(hline(chridx:end)==' ' | ...
                       hline(chridx:end)==9)+chridx-1 length(hline)+1]);
      s1=hline(chridx:whtidx-1);
      
      % bw apr 2004. this is copied from gethead.m, and prevents 
      % problems where the indexfile header has characters in that
      % are not acceptable in matlab variable names
      s1(find(s1=='.' | s1==':' | s1=='_' | s1=='@' | s1=='-'))='X';
      
      s2=hline(whtidx+1:end);
      
      if sum(isletter(s2))==0,
         h=setfield(h,s1,str2num(s2));
      else
         h=setfield(h,s1,s2);
      end
   else
      pctidx=length(curline)+1;
   end
   
   if pctidx>1,
      frcount=frcount+1;
      fline=curline(1:(pctidx-1));
      
      whtidx=[0 (find(fline==' ' | fline==9)) length(fline)+1];
      
      startidx=whtidx(find(diff(whtidx)>1))+1;
      endidx=[startidx(2:end)-1 length(fline)];
      for jj=1:length(startidx),
         ts=deblank(fline(startidx(jj):endidx(jj)));
         if sum(isletter(ts))==0,
            ts=str2num(ts);
         end
         flist{frcount,jj}=ts;
         %fprintf('-%s-\n',deblank(fline(startidx(jj):endidx(jj))));
      end
      
      if mod(frcount,1000)==0,
         fprintf('frame %d read...\n',frcount);
      end
   end
   
   lasteolidx=eolidx(ii);
end

