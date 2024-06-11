function setpapersize(width,height)
% set paper size for printing
% arguments width, height in centimetres
% or 'a4'

if isstr(width)
	if strcmp(lower(width), 'a4')
		width = 27;
		height = 18;
	end
    if strcmp(lower(width), 'a4portrait')
        width = 18;
        height = 27;
    end
end

% if width>height
% 	orient landscape
% else
% 	orient portrait
% end

set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 width height]);
