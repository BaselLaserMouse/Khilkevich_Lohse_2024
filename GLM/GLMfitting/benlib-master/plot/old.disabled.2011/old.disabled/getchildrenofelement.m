function children = getchildrenofelement(link,element)
% recursively analyse a linkage matrix to get all of the leaves
% under a particular node
% note that element needs to use the numbering system that linkage
% itself uses, i.e. data points are numbered 1-n, and higher-order
% clusters are numbered n+1:2n-1
% SO, to get all data points, do getchildrenofelement(link,2n-1)
% To get elements in either side of the first bifurcation, do
%  getchildrenofelement(link,2n-2)
% Or, just look at the linkage matrix, choose the row you want, r,
% and do getchildrenofelement(link,r+n)
%
% bw nov 2006

numleaves = size(link,1) + 1;

if element<=numleaves
  children = element;
else
  offspring = link(element-numleaves,1:2);
  children = [getchildrenofelement(link,offspring(2)) ...
	      getchildrenofelement(link,offspring(1))];
end
