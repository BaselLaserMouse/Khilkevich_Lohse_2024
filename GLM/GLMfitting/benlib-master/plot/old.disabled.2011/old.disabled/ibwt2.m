function z = ibwt2(z)

% inverse BWT2
% this is my strange three-way haar transform
% it's just like a haar except it takes pixels in threes, and
% therefore has a flat part, an even part and an odd part, not
% just flat and odd.

sz = size(z);

% we don't want to do it if it isn't square
sz = size(z);
if sz(1) ~= sz(2)
  fprintf('cant do it if its not square\n');
  return;
end

sz = sz(1);

% or if the dimensions aren't powers of three
numlevels = round(log(sz)/log(3));

resid = z;
newz = zeros(sz);
for ll = 1:numlevels
  csz = size(resid,1);
  todo = resid;
  resid = resid(1:csz/3,1:csz/3);
  todo(1:csz/3,1:csz/3) = 0;
  rtrans = ibwt2_onelevel(todo*(3^ll));
  sslevel = sz/csz;
  ss = ceil((1:sz)/sslevel);
  newz = newz + rtrans(ss,ss)/sslevel;
end

z = newz + resid/sz;
