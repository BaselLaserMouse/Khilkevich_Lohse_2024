% function fmovie=movphasesep(movie,startidx,stopidx,bwindow,btakepower,bzdc); 
%
% transform a stimulus movie into the phase-separated fourier
% domain.
%
% defaults startidx,stopidx=(1,end)
%          bwindow=0;
%          btakepower=1;
%          bzdc=0;
% 
% CREATED SVD 1/01
% Modified SVD 4/3/01: added log luminance
% Modified SVD 5/1/01: take power in fourier domain, not just amplitude.
%
function fmovie=movfullfft(movie,startidx,stopidx,bwindow,...
                                       btakepower,bzdc);

Xmax=size(movie,1);
Ymax=size(movie,2);
movlen=size(movie,3);

% take log of intensity before FT... ADDED SVD 3/30/01
% force movie to range 1-256:
% removed (SVD 4/3/01) temporarily?  see how pred are now (with new movresize)
if 0,
   moviemax=max(movie(:));
   if moviemax<=1,
      movie=movie*128+129;
   else
      movie=movie+1;
   end
   movie=log(movie);
end


if not(exist('startidx','var')) | startidx < 1 | startidx > movlen,
   startidx=1;
end
if not(exist('stopidx','var')) | stopidx < 1 | stopidx > movlen,
   stopidx=movlen;
end
if not(exist('bwindow','var')),
   bwindow=0;
end
if not(exist('btakepower','var')),
   btakepower=1;
end
if not(exist('bzdc','var')),
   bzdc=0;
end
movlen=stopidx-startidx+1;

if bzdc & min(movie(:))>=0 & max(movie(:))>bzdc,
   fprintf('movphasesep.m: bzdc=%.1f\n',bzdc);
   movie=movie-bzdc;
end

% mask with a hanning window. this replaces the gaussian masking
% procedure that was used in loadimfile.m/readfromimfile.m/movresize.m
if bwindow,
   filt=hanning2(Xmax,'periodic');
   movie(:,:,startidx:stopidx)=movie(:,:,startidx:stopidx) .* ...
       repmat(filt,[1 1 stopidx-startidx+1]);
end


pixcount=Xmax*Ymax;
xc=round((Xmax+1)/2);
yc=round((Ymax+1)/2);

%fmovie=fftshift(movie,1);
%fmovie=fftshift(fmovie,2);
fmovie=fft(movie(:,:,startidx:stopidx),[],1);
fmovie=cat(1,fmovie(xc:Xmax,:,:),fmovie(1:xc-1,:,:));
fmovie=fft(fmovie,[],2);
fmovie=cat(2,fmovie(:,yc:Ymax,:),fmovie(:,1:yc-1,:));
%fmovie=fftshift(fmovie,1);
%fmovie=fftshift(fmovie,2);