function cluster = getultimateclustermembership(link,element)
% given one element of a linkage matrix, work out which side of the
% primary bifurcation it is on.  in our data, this is whether it's
% in the V1-like cluster, or the V2-like cluster
% (though the values themselves, 1 and 2, are randomly assigned)
%
% bw nov 2006

numleaves = size(link,1) + 1;

[row,col] = find(link(:,1:2)==element);
newelement = numleaves+row;

if newelement==(numleaves*2-1)
  cluster = col;
else
  cluster = getultimateclustermembership(link,newelement);
end
