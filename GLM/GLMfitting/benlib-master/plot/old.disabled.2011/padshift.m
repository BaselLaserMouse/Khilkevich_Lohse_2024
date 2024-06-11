function b = padshift(a,p,padval)
% function b = padshift(a,p,padval)
% same as circshift but pads with padval not circular shift
% UGLY!
% and only works for up to 3d.
% though you could extend it easily to n-d
% bw jun 2005

if ~exist('padval') | isempty(padval)
  padval = nan;
end

if length(size(a))~=length(p)
  fprintf('Shift should be equal to dimensionality of matrix\n');
  b = nan;
  return;
end

if length(p)>3
  fprintf('Can only do 1, 2 or 3d. FIXME!!!\n');
  b = nan;
  return;
end

b = zeros(size(a))+padval;

a_start = max(-p+1,1);
b_start = max(p+1,1);

len = size(a)-max(a_start,b_start)+1;

if length(len)==1
  b(b_start:b_start+len-1) = a(a_start:a_start+len-1);

elseif length(len)==2
  b(b_start(1):b_start(1)+len(1)-1, ...
    b_start(2):b_start(2)+len(2)-1) ...
      = a(a_start(1):a_start(1)+len(1)-1, ...
	  a_start(2):a_start(2)+len(2)-1);

elseif length(len)==3
  b(b_start(1):b_start(1)+len(1)-1, ...
    b_start(2):b_start(2)+len(2)-1, ...
    b_start(3):b_start(3)+len(3)-1) ...
      = a(a_start(1):a_start(1)+len(1)-1, ...
          a_start(2):a_start(2)+len(2)-1, ...
          a_start(3):a_start(3)+len(3)-1)
end
