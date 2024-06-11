function p = getwhipatch3(pic_list,patch_list,num,sz)

% bw jan 2004
% for use with choosepatches6 and make_piclist
% gets the whitened version of the patch from:
whi_path = '/auto/fs2/willmore/matlab/stimgen/wnatrev/';

tmp = patch_list(num,1:3);
i = tmp(1);
y = tmp(2);
x = tmp(3);

orig_name = pic_list{i};
f = findstr(orig_name,'images/');
g = findstr(orig_name,'/');
g = g(end);

whi_name = [whi_path orig_name(f:g) num2str(sz) '/' orig_name(g+1:end-4) ...
	   'mat'];
	    
ld = load(whi_name);
im = ld.im;

p = im(y:y+255,x:x+255);
p = double(p);
