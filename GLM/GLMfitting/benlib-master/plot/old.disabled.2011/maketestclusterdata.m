template = [1 0 0 0 0 0 0 0 0 0];
data = rand(10) + repmat(template,[10 1]);

template = [0 1 1 0 0 0 0 0 0 0];
data2 = rand(10) + repmat(template,[10 1]);

data = [data; data2];

dist = pdist(data);
link = linkage(dist);
dendrogram(link);