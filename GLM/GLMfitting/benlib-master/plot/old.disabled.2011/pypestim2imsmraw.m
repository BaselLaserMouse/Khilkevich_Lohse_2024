% function [framecount,iconside]=pypestim2imsmraw(indexpath,indexfn,pixfn,repcount);
%
% convert pype format stimulus (pgm, one file per frame) to imsm
% format for analysis with cellxc toolbox. copy exact raw pgm
% contents into imsm. pypestim2imsm does a bunch of
% preprocessing/transforming
%
% indexpath - path to pype data
% indexfn - pype index file name
% pixfn - full path and name of imsm to save full stimulus
% repcount - (default 1) repeat each frame repcount times (TIMES
%            the number of repeats specified in the index file)
%
% created SVD 3/3/03, ripped off pypestim2imsm
%
function [framecount,iconside]=pypestim2imsmraw(indexpath,indexfn,pixfn,repcount);

if ~exist('repcount','var') | repcount<1,
   repcount=1;
end

[h,flist]=readindexfile([indexpath,indexfn]);

framelens=cat(1,flist{:,2});
framecount=length(framelens);

flist{1,1}
if findstr(flist{1,1},'/')
  
  %% HACK!! FIXME!!! get the pgms from upstairs if they're from the
  % optichoose library on /auto/sal2. only works on EtOH
  if strfind(flist{1,1},'/auto/sal2/optichoose/')
    for kk=1:length(flist)
      flist{kk,1} = ['/mnt/usb' flist{kk,1}];
    end
  end
  testimage=pgmRead(flist{1,1});
  fprintf(flist{1,1});
else
  fprintf([indexpath flist{1,1}]);
  testimage=pgmRead([indexpath,flist{1,1}]);
end

pixcount=size(testimage);
iconside=pixcount;
%croppix=round(pixcount(1)./2);  % assume 4 crf stim and 2 crf RC

if exist(pixfn,'file'),
   fprintf('WARNING! DELETING OLD OUTPUT FILE!\n');
   delete(pixfn);
end

fprintf('\n%s%s --> %s\n',indexpath,indexfn,pixfn);

FRSTEP=100;

curframe=0;
for stepidx=1:ceil(framecount/FRSTEP),
   startidx=curframe+1;
   stopidx=min([curframe+FRSTEP framecount]);
   fprintf('Transforming %d-%d/%d:\n',startidx,stopidx,framecount);
   
   mov=zeros([pixcount stopidx-startidx+1]);
   
   for fridx=startidx:stopidx,
      if findstr(flist{1,1},'/')
        im=pgmRead(flist{fridx,1});
      else
	im=pgmRead([indexpath,flist{fridx,1}]);
      end
      mov(:,:,fridx-startidx+1)=im;
   end
   
   curframe=stopidx;

   movout=zeros([pixcount sum(framelens(startidx:stopidx))]);
   
   localidx=0;
   for fridx=startidx:stopidx,
      movout(:,:,(localidx+1):(localidx+framelens(fridx)))=...
          repmat(mov(:,:,fridx-startidx+1),[1 1 framelens(fridx)]);
      localidx=localidx+framelens(fridx);
   end
   
   if repcount>1,
      fc=size(movout,3);
      movout=repmat(movout,[1 repcount 1]);
      movout=reshape(movout,pixcount(1),pixcount(2),repcount*fc);      
   end
   
   appendimfile(movout,pixfn,3);
end





