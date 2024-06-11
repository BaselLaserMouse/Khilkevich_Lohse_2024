function [y, bins] = plotpsthes(set,varargin)

if isfield(set,'set')
  set = set.set;
end

for ii = 1:length(set)
  subplot(length(set),1,ii);
  plotpsth(set(ii),varargin{:});
end
