% apr 28 2003 willmore.
% this goes through a load of .smap.mat files, which should already have
% been saved by getspotmapcontours.m (which in turn uses a bw modified 
% version of jam's p2mSpotmap.m.
% it adds all the spotmaps together to draw the famously horrible reese
% scotomamap.
% you can adjust spotsizethreshold so that it throws out spotmaps which
% used spots/lines which were too large.
% this is probably the best scotomamap program

% used for reese #17 scotoma mapping

d = jls('/auto/k5/willmore/ED02/spotmap/')

figure(1);
clf;

biggridx = [-6:0.02:6];
biggridy = [-6:0.02:6];

[biggridY, biggridX] = ndgrid(biggridy,biggridx);

tot = zeros(size(biggridY));
spotsizethreshold = 22;

for ii = length(d):-1:1
  ii
  d{ii}
  load(d{ii});
  if (rfinfo.spot_length < spotsizethreshold) & ...
	(rfinfo.spot_width < spotsizethreshold)
    rfinfo.rawz = rfinfo.rawz-min(rfinfo.rawz(:));
    rfinfo.rawz = rfinfo.rawz/max(rfinfo.rawz(:));
    [Y,X] = ndgrid(rfinfo.rawy,rfinfo.rawx);
    resamp = interp2(X,Y,rfinfo.rawz,biggridX,biggridY);
    resamp(find(isnan(resamp))) = 0;
    resamp=resamp/max(resamp(:));
    resamp=resamp+min(resamp(:));
    %resamp(find(resamp<0.5)) = 0;
    tot = tot+resamp;
    imagesc(tot);drawnow;%pause;
  end
end


tot = tot-min(tot(:));
tot = tot/max(tot(:));
%tot = min(tot,max(tot(:))/1.4);
%tot = 1-tot;
figure(2);
imagesc(tot);
axis equal;
