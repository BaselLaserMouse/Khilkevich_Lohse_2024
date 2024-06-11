function patch = getpatch(db,ii,colorflag)

% function patch = getpatch(db,ii,colorflag)
% get the iith patch from database db
% if colorflag == 1, get the color version of the patch instead


fname = db.images{db.imageids(ii)};

if colorflag == 1
  % convert b&w filename to its colour equivalent
  if isempty(findstr(fname,'malik'))
    fnd = findstr(fname,'.b.');
    fname = [fname(1:fnd(end)) 'c' fname(fnd(end)+2:end)];
  else
    fnd = findstr(fname,'/');
    fname = [fname(1:fnd(end)) 'color/' fname(fnd(end)+1:end)];
  end
  
  im = imread(fname);
  patch = im(db.corners(ii,1):db.corners(ii,3), ...
	     db.corners(ii,2):db.corners(ii,4),:);

  flip = db.flipvals(ii);
  
  if flip == 1
    patch(:,:,1) = fliplr(patch(:,:,1));
    patch(:,:,2) = fliplr(patch(:,:,2));
    patch(:,:,3) = fliplr(patch(:,:,3));
  elseif flip == 2
    patch(:,:,1) = flipud(patch(:,:,1));
    patch(:,:,2) = flipud(patch(:,:,2));
    patch(:,:,3) = flipud(patch(:,:,3));
  elseif flip == 3
    patch(:,:,1) = fliplr(flipud(patch(:,:,1)));
    patch(:,:,2) = fliplr(flipud(patch(:,:,2)));
    patch(:,:,3) = fliplr(flipud(patch(:,:,3)));
  end
  
  patch = double(patch);
  
else
  im = imread(fname);
  patch = im(db.corners(ii,1):db.corners(ii,3), ...
	     db.corners(ii,2):db.corners(ii,4));

  flip = db.flipvals(ii);
  
  if flip == 1
    patch = fliplr(patch);
  elseif flip == 2
    patch = flipud(patch);
  elseif flip == 3
  patch = flipud(fliplr(patch));
  end
  
  patch = double(patch);

end
