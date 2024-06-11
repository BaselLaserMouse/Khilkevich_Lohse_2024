function grat = makegrat(sz,freq,orient,phase,mn,amp);

%%%% quickgrat
% makes a grating
% sz is size in pixels
% freq is SF in cycles/image
% orient, phase in radians
% mn = mean, amp = amplitude
% BW 11-20-02

ctr = sz/2+1;
w = 2*pi*freq/sz;

[x,y]=meshgrid(-ctr+1:ctr-2,-ctr+1:ctr-2);

x_rot = x.*cos(orient) + y.*sin(orient);
   
grat = cos(w*x_rot + phase) ;

grat = grat*(amp/2)+mn;
   
