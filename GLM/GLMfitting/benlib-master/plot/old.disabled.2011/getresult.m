function y = getresult(filename)
% bw nov 2006
% helper function for getting data from a directory of files
% use with applytodir/qapplytodir

out = load(filename);
y = out.result;

