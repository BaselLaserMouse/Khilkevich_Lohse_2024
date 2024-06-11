function [data,fname]=damFileGunzipAndRead(fname)
% function data=damFileGunzipAndRead(fname)
%
% Reads a .dam or .dam.gz file, uncompressing it to a 
% temporary file if necessary

% determine if it is a compressed file
compressed = false;

if fname(end-2:end)=='.gz'
  % user has asked for a compressed file
  compressed = true;
elseif ~exist(fname,'file') & exist([fname '.gz'],'file')
  % user asked for uncompressed file but it doesn't exist, so
  % check if a compressed version exists
  fname = [fname '.gz'];
  compressed = true;
end

fprintf([ 'Loading ' fname '...\n']);

if compressed
  tname = tempname;
  cmdstr=['gunzip -c ' fname ' > ' tname];
  unix(cmdstr);
  data = damFileRead(tname);
  delete(tname);
else
  data = damFileRead(fname);
end
