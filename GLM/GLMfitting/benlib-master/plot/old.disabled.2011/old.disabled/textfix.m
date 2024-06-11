function y=textfix(x)

bits = strsplit(x,'_');

y = bits{1};
for ii = 2:length(bits)
  y = [y '\_' bits{ii}];
end