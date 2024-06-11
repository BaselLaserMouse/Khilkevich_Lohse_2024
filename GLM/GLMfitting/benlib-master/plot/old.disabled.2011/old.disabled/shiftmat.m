function shifted = shiftmat(mtx,offset,padval)
% function shifted = shiftmat(mtx,offset,padval)
% bw mar 2004
% shift each row of a matrix offset to the right
% if padval is not defined, wrap ends.
% otherwise, pad with padval

display = 0;

if ~exist('padval','var')
  % then wrap

  if display==1
    fprintf('wrapping\n');
  end
  
  if offset>0
    shifted = mtx(:,[end-offset+1:end 1:end-offset]);
  elseif offset<0
    offset = -offset;
    shifted = mtx(:,[1+offset:end 1:offset]);
  else
    shifted = mtx;
  end
  
else
  % pad
  
  if display==1
    fprintf(['padding with ' num2str(padval) '\n']);
  end
  
  shifted = zeros(size(mtx))+padval;
  
  if offset>0
    shifted(:,offset+1:end) = mtx(:,1:end-offset);
  elseif offset<0
    offset = -offset;
    shifted(:,1:end-offset) = mtx(:,offset+1:end);
  else
    shifted = mtx;
  end
  
end

