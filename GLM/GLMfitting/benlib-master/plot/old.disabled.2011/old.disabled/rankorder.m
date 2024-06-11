function rank = rankorder(matrix)

vector = matrix(:);

vector(:,2) = [1:length(vector)]';
sorted = sortrows(vector);

ranked = sorted(:,2);
ranked(:,2) = [1:length(vector)]';

unsorted = sortrows(ranked);

rank = unsorted(:,2);

rank = reshape(rank,size(matrix));