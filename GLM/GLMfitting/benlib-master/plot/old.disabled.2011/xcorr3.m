function r = xcorr3(bigger, smaller)

% sept 2003 willmore
% this function takes two 3d matrices, and xcorrs them in the
% 3rd dimension.  e.g. if you have a filter f(x,y,t) and a stimulus
% s(x,y,t), and you want to xcorr them to find the response of
% the filter to the stimulus. only gives the 'valid' part of the 
% cross-correlation (accorinding to rules for conv2)
%
% you can check that it's doing the right thing by comparing it 
% with xcorr3slow, which in turn you can compare with conv
%
% you will never understand this but it is devilishly fast
% if only i could get rid of that last little loop...
%
% slight speed improvement mar 2005 willmore

[wid1 wid2 blen] = size(bigger);

wid = wid1*wid2;

slen = size(smaller,3);

b2d = reshape(bigger,[wid blen]);
s2d = fliplr(reshape(smaller,[wid slen]));

m = s2d'*b2d;

for ii = 2:slen
  m(ii,:) = [m(ii,ii:blen) m(ii,1:ii-1)];
end

r = sum(m,1);
