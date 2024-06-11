function p = getpatch3(pic_list,patch_list,num)

% bw jan 2004
% for use with choosepatches6 and make_piclist

tmp = patch_list(num,1:3);
i = tmp(1);
y = tmp(2);
x = tmp(3);
if isempty(findstr(pic_list{i},'.mat'))
  im = imread(pic_list{i});
else
  ld = load(pic_list{i});
  im = ld.im;
end

p = im(y:y+255,x:x+255);
p = double(p);
