% function [h,flist]=gethead(fn)
function [h,flist]=gethead(fn)

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
for ii=1:length(eolidx),
   curline=char(buffer((lasteolidx+1):(eolidx(ii)-1))');

   pctidx=min(find(curline=='%'));
   if ~isempty(pctidx) & (pctidx==1 | nargout>1),
      curline=curline(pctidx+1:end);
      
      chridx=min(find(curline~=' ' & curline~=9));
      whtidx=min([find(curline(chridx:end)==' ' | ...
                       curline(chridx:end)==9)+chridx-1 length(curline)+1]);
      s1=curline(chridx:whtidx-1);
      if strcmp(s1,'1'),
         disp('skipping header field 1'),
      else
         s1(find(s1=='.' | s1=='@' | s1=='-' | s1==':' | s1=='_'))='X';
         s2=curline(whtidx+1:end);
         
         if pctidx==1,
            if sum(isletter(s2))==0,
               h=setfield(h,s1,str2num(s2));
            else
               h=setfield(h,s1,s2);
            end
         else
            flist{length(flist)+1}=s1;
         end
      end
   end
   lasteolidx=eolidx(ii);
end

