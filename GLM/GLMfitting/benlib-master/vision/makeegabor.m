function y=makeegabor(size, xorigin, yorigin, period, elong, phase, theta, sd);

phi = -theta;	% theta is the angle between the +ve y-axis and the
					% centre line of the grating. Phi is the angle from
               % the +ve x-axis to the axis along which the grating
               % varies
               
freq = 1/period; % It's easier to input as period than as frequency

%xorigin = xwidth/2 + 1; 
%yorigin = ywidth/2 + 1;	% The centre of the array, plus 1 to make
								% fourier transforms work properly
[i,j] = ndgrid(1:size,1:size);                    

ypos = i-yorigin; 	    % same, along y-axis
xpos = j-xorigin;		% distance along x-axis from origin
dist_sqr = xpos^2 + ypos^2; 	% square of radial distance
     							% from origin
    
% rotate axes through angle phi
xtrans = xpos.*cos(phi)-ypos.*sin(phi);
ytrans = xpos.*sin(phi)+ypos.*cos(phi);

% grating:
y = sin(2*pi*freq*xtrans + phase);

% multiplied by gaussian:    
dsq = xtrans.^2+(ytrans/elong).^2;      
y = y .* exp(-dsq/(2*sd^2));
