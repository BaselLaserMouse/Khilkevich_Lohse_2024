% function plotraster0(raster,binsize,startframe,stopframe);
%
% raster is time X trial matrix
%
function plotrasterbw(raster,binsize,startframe,stopframe);

framecount=size(raster,1);
trialcount=size(raster,2);

if ~exist('binsize','var') | binsize<1,
   binsize=1;
end
if ~exist('startframe','var') | startframe<1,
   startframe=1;
end
if ~exist('stopframe','var') | stopframe<1 | stopframe>framecount,
   stopframe=framecount;
end

raster=raster(startframe:stopframe,:);

if binsize>1,
   bincount=ceil(framecount/binsize);
   addframes=bincount*binsize-size(raster,1);
   raster=cat(1,raster,nan.*ones(addframes,trialcount));
   raster=mean(reshape(raster,binsize,bincount,trialcount));
   raster=reshape(raster,bincount,trialcount);
else
   bincount=framecount;
end

raster=raster';
resp=nanmean(raster);

tbinms=binsize;
tt=0:tbinms:(bincount-1)*tbinms;

plot(tt,resp,'k-','Linewidth',1);
a=axis;
axis([tt(1) tt(end) 0 a(4)]);
hold on
rr=linspace(0,a(4),trialcount+1);
rr=rr(2:end)-(rr(2)-rr(1))/2;
rmax=max(raster(:))*1.5;
imagesc(tt,rr,-raster,[-rmax 0]);
%plot(tt,resp,'k-','Linewidth',1);

hold off


