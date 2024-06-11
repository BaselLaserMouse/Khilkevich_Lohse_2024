cd ~/Documents/science/talks/2005-sfn/sfn-figs/images
sz = ceil([384, 512]*.75);
screen = zeros(sz)+73;
ctr=size(screen)/2+1;
screen(ctr(1),ctr(2)) = 255;
patchpos = ctr;
patchpos(2) = patchpos(2)+40;
patchsz = 128;

images = [9 103 104 108 113 115 116 119 122 127 128 131 134 148 149 ...
	  169 185 200 219 257 260 288  26 52 67 69 85 99];

nreps = 2;
clear mov;
for ii = 1:length(images)
  for rep = 1:nreps
  numstr = sprintf('%-.5d',images(ii));
  im = imread(['image_' numstr '.pgm']);
  im = double(im);
  if 0 & ((ii==1) | (ii==length(images)))
    im = drawcircle(im,0,0,size(im,1)/6,size(im,1)/6+3);
  end
  screen(patchpos(1):patchpos(1)+patchsz-1, patchpos(2):patchpos(2)+patchsz-1) = imresize(im,128/size(im,1));
  image(screen);axis image;axis off;drawnow;
  mov((ii-1)*nreps+rep) = im2frame(screen,colormap(gray(256)));
  %images(ii),pause
  end
end

%movie2avi(mov,'movie.avi');
mpgwrite(mov,mov(1).colormap,'movie.mpg',[1 0 0 0 1 1 1 1])