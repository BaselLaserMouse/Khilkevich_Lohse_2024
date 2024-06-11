

function [qids, qgs] = readClusterQualCSV(filename)


fid = fopen(filename);
C = textscan(fid, '%s%s');
fclose(fid);

qids = cellfun(@str2num, C{1}(2:end), 'uni', false);
ise = cellfun(@isempty, qids);
qids = [qids{~ise}];

qgs=str2num(cell2mat(C{2}(2:end)));
