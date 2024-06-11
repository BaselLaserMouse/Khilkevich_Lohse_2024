function plotradius(mat,r)

sz_y = size(mat,1)/2+1;
sz_x = size(mat,2)/2+1;

func = [];
step = pi/16;
for th = 0:step:2*pi-step
  func(end+1) = mat(sz_y+round(r*cos(th)),sz_x+round(r*sin(th)));
end

plot(180/pi*(0:step:2*pi-step),func);