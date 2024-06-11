function plotimageresp(stim,r,n)

if ~exist('n')
  n = 1;
end

fprintf(['Exponent = ' num2str(n) '\n']);
r_t = sign(r).*(abs(r).^n);

plot(r_t(:,1),r_t(:,2),'.');
hold on;

showsz = (max(r_t(:))-min(r_t(:)))/10;
mn = min(stim(:));
mx = max(stim(:));

alphamask = mask(64,26,30);


for ii = 1:size(r,1)
  h = imagesc(flipud(stim(:,:,ii)),[mn mx]);
  set(h,'AlphaData',alphamask);
  set(h,'XData',[r_t(ii,1)-showsz/2 r_t(ii,1)+showsz/2]);
  set(h,'YData',[r_t(ii,2)-showsz/2 r_t(ii,2)+showsz/2]);
end
hold off;
colormap(gray(256));
axis image;

