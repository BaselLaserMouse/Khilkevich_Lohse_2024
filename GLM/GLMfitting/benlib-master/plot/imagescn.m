function varargout = imagescn(varargin)
% function varargout = imagescn(varargin)
%
% imagesc but with colour axes that are 
% symmetric about zero

  h = imagesc(varargin{:});
  im = get(h, 'CData');
  mx = max(abs(im(:)));
  try
	  clim([-mx mx]);
  end
  
  if nargout == 1
  	varargout = {h};
  end
