% function pypestim2imsm(indexpath,indexfn,wavfn,fftfn,smfn,lgfn,repcount);
%
% convert pype format stimulus (pgm, one file per frame) to imsm
% format for analysis with cellxc toolbox. in parallel computes
% pixel downsampled, phase-separated fourier domain, and wavelet
% domain representations of the stimulus.  also computes stimulus
% autocorrelation data for each imsm file and saves it in an
% auxilliary .mat file.
%
%
% created SVD 6/02
%
function pypestim2imsm(indexpath,indexfn,smfn,lgfn,repcount);

if ~exist('repcount','var') | repcount<1,
   repcount=1;
end

[h,flist]=readindexfile([indexpath,indexfn]);

framelens=cat(1,flist{:,2});
framecount=length(framelens);

testimage=pgmRead([indexpath,flist{1,1}]);
pixcount=size(testimage);
croppix=round(pixcount(1)./2.*3);  % assume 3 crf stim and 2 crf RC

[fmask,crop]=movfmask(pixcount(1),1.1,croppix);
[fftmask]=movfmask(16,1,16);
smallfmt=0;
dosmooth=1;

if exist(smfn,'file'),
   fprintf('WARNING! DELETING OLD OUTPUT PIX FILE!\n');
   delete(smfn);
end
if exist(lgfn,'file'),
   fprintf('WARNING! DELETING OLD OUTPUT PIX FILE!\n');
   delete(lgfn);
end

fprintf('\n%s%s --> %s\n',indexpath,indexfn,smfn);

FRSTEP=50;
%fftmask=repmat(movfmask(16,1,16),[1,1,50]);

curframe=0;

for stepidx=1:ceil(framecount/FRSTEP),
   startidx=curframe+1;
   stopidx=min([curframe+FRSTEP framecount]);
   fprintf('Transforming %d-%d/%d:\n',startidx,stopidx,framecount);
   
   mov=zeros([pixcount stopidx-startidx+1]);
   
   for fridx=startidx:stopidx,   
      im=pgmRead([indexpath,flist{fridx,1}]);
      mov(:,:,fridx-startidx+1)=im;
   end
   
   curframe=stopidx;
      
   smmov=movresize(mov,16,fmask,crop,smallfmt,dosmooth);
   lgmov=movresize(mov,32,fmask,crop,smallfmt,dosmooth);
   
   ssize=size(smmov);
   smmovout=zeros([ssize(1:2) sum(framelens(startidx:stopidx))]);

   lsize=size(lgmov);
   lgmovout=zeros([lsize(1:2) sum(framelens(startidx:stopidx))]);
   
   localidx=0;
   for fridx=startidx:stopidx,
      smmovout(:,:,(localidx+1):(localidx+framelens(fridx)))=...
          repmat(smmov(:,:,fridx-startidx+1),[1 1 framelens(fridx)]);
      lgmovout(:,:,(localidx+1):(localidx+framelens(fridx)))=...
          repmat(lgmov(:,:,fridx-startidx+1),[1 1 framelens(fridx)]);      
      localidx=localidx+framelens(fridx);
   end
   
   if repcount>1,
      fc=size(wmovout,5);
      smmovout=repmat(smmovout,[1 repcount 1]);
      smmovout=reshape(smmovout,16,16,repcount*fc);
      lgmovout=repmat(smmovout,[1 repcount 1]);
      lgmovout=reshape(smmovout,32,32,repcount*fc);
   end
 
   appendimfile(smmovout,smfn,3);
   appendimfile(lgmovout,lgfn,3);

end

% calculate stimulus AC and save in same location
calcsSA2(smfn);
calcsSA2(lgfn);





