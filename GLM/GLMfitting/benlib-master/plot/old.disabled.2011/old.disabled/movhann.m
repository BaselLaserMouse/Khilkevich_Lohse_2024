% function fmoviep=movpower(movie,startidx,stopidx,bwindow,btakepower,.. 
%                           bzdc,btempnl); 
%
% transform a stimulus movie into the fourier power domain.
% 
% startidx,stopidx - start and stop frames (default 0,0, keep all)
% bwindow - apply hanning window before fft (default 0, off)
% btakepower - take fourier amplitude to this power (default 1)
% bzdc - subtract this value from movie before window, then add back
%        before fourier transform... unless btempnl~=0, in which case
%        negative component gets stuck in an weak sf channel (def 0)
% btemnpnl - experimental code for replacing high sf channels with
%            nl-transformed temporal information (default 0)
%
% CREATED SVD 4/25/02  Hacked from movphasesep.m
%
function fmoviep=movhann(movie,startidx,stopidx,bwindow,...
                          btakepower,bzdc,btempnl);

Xmax=size(movie,1);
Ymax=size(movie,2);
movlen=size(movie,3);

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
if not(exist('btempnl','var')),
   btempnl=0;
end
movlen=stopidx-startidx+1;

pixcount=Xmax*Ymax;
xc=round((Xmax+1)/2);
yc=round((Ymax+1)/2);

movie=movie(:,:,startidx:stopidx);

if bzdc & btempnl, 
   fprintf('movpower.m: bzdc=%.1f\n',bzdc);
   movie=movie-bzdc;
   bdc=0;
elseif bzdc,
   %fprintf('movpower.m: bzdc=%.1f\n',bzdc);
   movie=movie-bzdc;
   bdc=bzdc;
else
   bdc=0;
end
if bwindow,
   %filt=(hanning(Xmax,'periodic') * hanning(Ymax,'periodic')');
   filt=hanning2(Xmax,'periodic');
   
   movie=movie .* repmat(filt,[1 1 stopidx-startidx+1]) + bdc;
end

fmoviep = movie;