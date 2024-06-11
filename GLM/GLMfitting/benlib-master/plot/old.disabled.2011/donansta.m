sz = 16;
nstm = 500;

stim = rand(nstm,sz^2);

f = zeros(3,sz^2);
for frame = 1:3
  tmp = makeegabor(sz,sz/2,sz/2,6,1,0,pi/4,3);
  f(frame,:) = tmp(:)';
end

mult = stim*f';
r = mult(1,:)+mult(2,[2:end 1])+mult(3,[3:end 1:2]);
