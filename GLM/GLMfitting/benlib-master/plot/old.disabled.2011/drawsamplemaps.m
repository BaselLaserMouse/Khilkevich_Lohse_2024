% this goes through a whole load of samplemaps produced by 
% getsamplemapcontours.m and plots them on top of each other so you
% can see which parts of space were sampled by the spotmaps. this is like
% drawspotmaps.m (which is obsolete) but performs the same function as
% a putative drawrawsamplemaps.m except that the colourmaps are different

% this function was used to demonstrate the scotoma problems in
% Reese well 17

d = jls('/auto/k5/willmore/ED02/samplemap/ED03/*');

figure(1);
clf;
%skipped = 0;

tot = zeros(420,560);
for ii = 1:length(d)
  load(d{ii});
%  if ~(length(rfinfo.x)>50)
    clf;
    a = fill(rfinfo.x,rfinfo.y,'k');
    %set(a,'FaceAlpha',5/length(d));
    set(a,'EdgeColor','none');
    set(a,'EraseMode','none');
    axis off;
    axis image;
    axis([0 6 -6 -0]);
    [tmp,map] = capture(1);
    tot = tot+tmp;
    %pause;
%  else
%    skipped = skipped + 1;
%  end
end

%disp(skipped);

tot = tot-min(tot(:));
tot = tot/max(tot(:));
%tot = min(tot,max(tot(:))/1.4);
tot = 1-tot;
figure(2);
imagesc(tot);
axis equal;
