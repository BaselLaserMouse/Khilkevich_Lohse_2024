function y = imagesc0(varargin)

mx = max(abs(varargin{1}(:)));
if mx==0
    mx = 1;
end
varargin{end+1} = [-mx mx];

try
    y = imagesc(varargin{:});
catch
    keyboard
end
colormap(redbluemap);
