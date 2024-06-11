function imexport(fignum, finalres)
  % function imexport(fignum, finalres)
  %
  % resample images in a given (or current) figure
  % so that they are not antialiased noticeably when exported
  % final resolution will be between finalres and 2xfinalres
  
if ~exist('fignum', 'var')
  fignum = gcf;
end

if ~exist('scale', 'var')
  finalres = 512;
end

axes = fignum.Children;
for ii = 1:length(axes)
  ax = fignum.Children(ii);
  objects = ax.Children;
  for jj = 1:length(objects)
    obj = objects(jj);
    %class(obj)
    if strcmp(class(obj),'matlab.graphics.primitive.Image')
      [ySz, xSz] = size(obj.CData);
      scale = max(2.^ceil(log2(finalres./[xSz ySz])));
      
      xLim = obj.XData;
      % xLim is the centres of the pixels
      % find the edges of the image
      xScale = abs(xLim(2)-xLim(1)+1)/xSz;
      xEdges = [xLim(1)-xScale/2 xLim(2)+xScale/2];
      % new pixels should be centred 1/2 a pixel in from the edges
      xLimNew = [xEdges(1)+xScale/scale/2 xEdges(2)-xScale/scale/2];
      
      obj.XData = xLimNew;
      
      yLim = obj.YData;
      % yLim is the centres of the pixels
      % find the edges of the image
      yScale = abs(yLim(2)-yLim(1)+1)/ySz;
      yEdges = [yLim(1)-yScale/2 yLim(2)+yScale/2];
      % new pixels should be centred 1/2 a pixel in from the edges
      yLimNew = [yEdges(1)+yScale/scale/2 yEdges(2)-yScale/scale/2];
      obj.YData = yLimNew;

      dat = imresize(obj.CData, scale, 'nearest');
      obj.CData = dat;
    end
  end
end