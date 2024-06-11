function showheatmap(lum, color, border)

if ~exist('border','var')
  border = 0;
end

set(gcf,'DoubleBuffer','on');

lum = double(lum);

%cmap = jet;
cmap = flipud(redgreen);
sm = sum(cmap,2);  % make sure the colormap has all same luminance
cmap = cmap./repmat(sm,[1 3]);
div  = (max(abs(color(:))))/(size(cmap,1)-3)*2;
cmap_zero = size(cmap,1)/2;
col_idx =  cmap_zero+floor(color/div);

cols = reshape(cmap(col_idx,:),[size(color,1) size(color,2) size(cmap,2)]);

toshow = repmat(lum,[1 1 3]).*cols;

image(toshow/max(toshow(:)));

if border
  hold on;
  x = size(im,2)
  y = size(im,1)
  h = line([0.5 0.5],[0.5 x+.5]);
  set(h,'Color','k');
  h = line([0.5 x+.5],[y+.5 x+.5]);
  set(h,'Color','k');
  h = line([y+.5 x+.5],[y+.5 0.5]);
  set(h,'Color','k');
  h = line([y+.5 0.5],[0.5 0.5]);
  set(h,'Color','k');
  hold off;
end
