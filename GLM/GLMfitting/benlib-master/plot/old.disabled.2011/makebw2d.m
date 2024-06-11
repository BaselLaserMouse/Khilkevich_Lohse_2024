function z = makebw2d(sz,y,x,scale,or,ph)
% the heart of the BWT transform

% scale should be 1, 3, 9 ...
% or should be 1,2,3,4,5 (5 is DC)
% ph should be 1,2
% 5,2 is interpreted as 5,1 (DC)

% this is the most-often-used BWT code
% bw nov 2006

b(1,:) = [-1 -1 -1  2  2  2 -1 -1 -1];
b(2,:) = [-1 -1 -1  0  0  0  1  1  1];

b(3,:) = [-1 -1  2 -1  2 -1  2 -1 -1];
b(4,:) = [-1  1  0  1  0 -1  0 -1  1];

b(5,:) = [-1  2 -1 -1  2 -1 -1  2 -1];
b(6,:) = [-1  0  1 -1  0  1 -1  0  1];

b(7,:) = [ 2 -1 -1 -1  2 -1 -1 -1  2];
b(8,:) = [ 0  1 -1 -1  0  1  1 -1  0];

b(9,:) = [ 1  1  1  1  1  1  1  1  1];

for ii = 1:9
  b(ii,:) = b(ii,:)/sum(b(ii,:).^2);
end

ind = (or-1)*2+ph;
ind = min(ind,9);

h = reshape(b(ind,:),3,3);

h = imresize(h,scale,'nearest');

z = zeros(sz);

z(y:y+size(h,1)-1,x:x+size(h,2)-1) = h;

z = z(1:sz,1:sz);
