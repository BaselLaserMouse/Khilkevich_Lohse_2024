r = respload('e0004.edrev3.006.mat');
s = loadimfile('wnatrev2004.96.index60.1.pix16');

g = makeegabor(16,9,9,4,1,0,0,3);

r = zeros(size(s,3),1);
for ii = 1:size(s,3)
  r(ii) = sum(sum(g.*(s(:,:,ii))));
end
r([2:end]) = r([1:end-1]);

%function y=makeegabor(size, xorigin, yorigin, period, elong, phase, theta, sd);

len = length(r);
s = s(:,:,1:len);

for ii = 1:size(s,3)
  ii
  tmp = s(:,:,ii);
  tmp = tmp-mean(tmp(:));
  %tmp = (hanning(16)*hanning(16)').*tmp;
  tmp = fftshift(abs(fft2(tmp)));
  tmp(9,9)=0;
  s(:,:,ii)= tmp;
end

s = reshape(s,256,len);
cov = s * s';
[e,d] = eig(cov);
d = diag(d);


%r=ones(size(r));
r = r';
r(find(~isfinite(r))) = 0;

if 0
sta = zeros(256,0);
for lag = 1:10
  thisr = zeros(size(r));
  thisr(1:end-lag+1) = r(lag:end);
  sta(:,end+1) = sum(s.*thisr(ones(256,1),:),2); 
end
end

sta = getsta(s,r',[-2:5]');

for ii = 1:size(sta,2)
  subplot(size(sta,2),1,ii);
  show(reshape(sta(:,ii),16,16));
end
  
