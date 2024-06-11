function h = show(im,range,cmap,fixzero,border)

set(gcf,'DoubleBuffer','on');

if ~exist('range','var')
  range = [min(im(:)) max(im(:))];
end

if isempty(range)
  range = [min(im(:)) max(im(:))];
end

if ~exist('cmap','var')
  cmap = gray(256);
end

if isempty(cmap)
  cmap = gray(256);
end

if ~isreal(im)
  im = abs(im);
end

if exist('fixzero','var')
  if ~isempty(fixzero)
    if fixzero
      mx = max(abs(range));
      range = [-mx mx];
    end
  end
end

if range(1)==range(2)
  range(1) = -1;
  range(2) = 1;
end

if ~exist('border','var')
  border = 0;
end

colormap(cmap);
imagesc(im,range);
axis off;
axis image;

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
