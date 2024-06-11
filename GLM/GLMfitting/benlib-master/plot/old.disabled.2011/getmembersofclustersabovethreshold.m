function members = getmembersofclustersabovethreshold(link,threshold)
% get a cell matrix containing the membership of all clusters that
% are separated by more than a threshold distance.
%
% this relies on the distances in the linkage matrix (third column)
% increasing monotonicallly.  this is not always the case but your
% clusters are pretty screwed up if it's not true.
%
% bw nov 2006

f = find(link(:,3)>threshold);

members = {};
for ii = 1:length(f)
  for jj = 1:2
    possible = link(f(ii),jj);
    themembers = getchildrenofelement(link,possible);
    alreadydone = 0;
    for kk = 1:length(themembers)
      if ~isempty(find(cell2mat(members)==themembers(kk)))
        alreadydone = 1;
      end
    end
    if ~alreadydone
      members{end+1} = themembers;
    end
  end
end
