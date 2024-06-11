function str = cell2str(cellarray,padding)

str = '';
if ~exist('padding','var')
  padding = [];
end

for ii = 1:length(cellarray)
  str = [str cellarray{ii} padding];
end

str = str(1:end-length(padding));