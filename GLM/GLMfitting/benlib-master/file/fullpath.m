function [fullname, dirname, filename] = fullpath(shortname)

shortname = fix_slashes(shortname);
f = find(shortname==filesep, 1, 'last');

dirname = shortname(1:f-1);
filename = shortname(f+1:end);

oldpath=pwd;
cd(dirname);
dirname=pwd;
cd(oldpath);

fullname = [dirname filesep filename];
