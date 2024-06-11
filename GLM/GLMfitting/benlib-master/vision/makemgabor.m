function y=makemgabor(size, xorigin, yorigin, period, phase, theta, sd);

xwidth = size;	% width of array to create
ywidth = size;	% height of array to create

phi = -theta;	% theta is the angle between the +ve y-axis and the
					% centre line of the grating. Phi is the angle from
               % the +ve x-axis to the axis along which the grating
               % varies
               
freq = 1/period; % It's easier to input as period than as frequency

%xorigin = xwidth/2 + 1; 
%yorigin = ywidth/2 + 1;	% The centre of the array, plus 1 to make
								% fourier transforms work properly
                        
for i = 1:ywidth;
   for j = 1:xwidth;
      
      xpos = j-xorigin - 0.5;		% distance along x-axis from origin
      ypos = i-yorigin - 0.5; 	% same, along y-axis
      dist_sqr = xpos^2 + ypos^2; 	% square of radial distance
     											% from origin
      
      xtrans = xpos*cos(phi)-ypos*sin(phi);
      		% rotate x-axis through angle phi
      
      y(i,j) = sin(2*pi*freq*xtrans + phase);
      		% grating
      
      y(i,j) = y(i,j) .* exp(-dist_sqr/(2*sd^2));
      		% multiplied by gaussian
      
   end;
end;
