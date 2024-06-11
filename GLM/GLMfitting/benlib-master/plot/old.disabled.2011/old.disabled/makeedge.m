function out = makeedge(sz, offset,phi)
% make a sharp edge stimulus
% bw nov 2006

[xpos,ypos] = meshgrid(1:sz,1:sz);

ctr = sz/2+1;
xpos = xpos - ctr;
ypos = ypos - ctr;

% rotate axes through angle phi
xtrans = xpos.*cos(phi)-ypos.*sin(phi);
ytrans = xpos.*sin(phi)+ypos.*cos(phi);

% offset edge from centre
xtrans = xtrans-offset;

out = xtrans>0;
