function y=makemgauss(size, xorigin, yorigin, sd);

xwidth = size;	% width of array to create
ywidth = size;	% height of array to create

for i = 1:ywidth;
   for j = 1:xwidth;
      
      xpos = j-xorigin;		% distance along x-axis from origin
      ypos = i-yorigin; 	% same, along y-axis
      dist_sqr = xpos^2 + ypos^2; 	% square of radial distance
     											% from origin
                                      
      y(i,j) = 1/(sd^2*2*pi) * exp(-dist_sqr/(2*sd^2));
      		% multiplied by gaussian
      
   end;
end;
