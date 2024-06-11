% apr 28 2003 willmore
% goes through all spotmap p2ms, saving files with crucial samplemap info in
% them. use with drawsamplemaps.m

basedir = '/auto/data/archive/ed_data/';
dirpat  = 'e2004-04-0*/';
savedir = '/auto/k5/willmore/ED02/samplemap';

dirlist = jls([basedir dirpat '*spot*.p2m']);

opts.smooth = 1;

spotcontours = cell(0);

for ii = 1:length(dirlist)
  loadname = dirlist{ii};
  disp(loadname);
  pf = p2mLoad(loadname);
  fnd = findstr(loadname,'/');
  rfinfo = p2msamplemap(pf,opts);
  savename = [savedir loadname(fnd(end):end-4) '.smap.mat'];
  save(savename,'rfinfo');
  spotcontours{ii,1} = rfinfo.x;
  spotcontours{ii,2} = rfinfo.y;
end
