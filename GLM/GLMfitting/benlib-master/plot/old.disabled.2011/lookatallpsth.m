
parentdir = '/auto/k5/willmore/projects/ED02/';

subdirs = {'pfft-14-nosmooth';'sfft-14-nosmooth';'space-14-nosmooth'};
	   
suffix = '.natrev.pfft.mat';

cellname = 'e0017';

for ii = 1:length(subdirs)
  fname = [parentdir subdirs{ii} cellname suffix];
  l = load(fname);
  
  