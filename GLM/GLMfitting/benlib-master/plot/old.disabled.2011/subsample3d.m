function ss = subsample3d(im,ssz)
%subsample an image, colour or indexed

[ysz xsz zsz] = size(im);

ss = zeros(ysz,xsz,zsz);

for i = 1:ssz
   for j = 1:ssz
      add = im(i:end,j:end,:);
      [yad xad zad] = size(add);
      ss(1:yad,1:xad,:) = ss(1:yad,1:xad,:) + add;
   end
end

ss = ss/(ssz^2);
ss = ss(1:ssz:end,1:ssz:end,:);

if mod(ysz,ssz) ~= 0 
   ss = ss(1:end-1,:,:);
end

if mod(xsz,ssz) ~= 0 
   ss = ss(:,1:end-1,:);
end
