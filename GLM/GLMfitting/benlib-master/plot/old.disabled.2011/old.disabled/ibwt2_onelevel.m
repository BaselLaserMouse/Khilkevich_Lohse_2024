function z = ibwt2_onelevel(z)

% this is my strange three-way haar transform
% it's just like a haar except it takes pixels in threes, and
% therefore has a flat part, an even part and an odd part, not
% just flat and odd. this may be useful for kernel estimation,
% where we want to be centred on something, rather than cutting
% everything in two.

% we don't want to do it if it isn't square
sz = size(z);
if sz(1) ~= sz(2)
  fprintf('cant do it if its not square\n');
  return;
end

% or if the dimensions aren't divisible by three
if (floor(sz(1)/3)~=(sz(1)/3)) | (floor(sz(2)/3)~=(sz(2)/3))
  fprintf('cant do it if its not divisible by three\n');
  return;
end

sz = sz(1);
ssz = sz/3;

% make 3 column vectors for the 3 3-haar filters
fflat = [ 1  1  1]'/sqrt(3);
fodd  = -1 * [-1  0  1]'/sqrt(2);
feven = [-1  2 -1]'/sqrt(6);

funcs = [fflat fodd feven];

ss = ceil((1:ssz*3)/3);
recon = zeros(sz);

for ii = 1:3
  for jj = 1:3
    fn_y = funcs(:,ii);
    fn_x = funcs(:,jj)';
    fn   = fn_y * fn_x;
    coeff = z((ii-1)*ssz+1:ii*ssz,(jj-1)*ssz+1:jj*ssz);
    scoeff= coeff(ss,ss);
    recon = recon + scoeff .* repmat(fn,ssz,ssz);
  end
end

z = recon;