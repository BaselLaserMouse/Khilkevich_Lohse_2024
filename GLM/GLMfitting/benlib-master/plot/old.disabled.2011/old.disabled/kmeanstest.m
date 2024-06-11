
x = rand(100,3);
x(:,1) = x(:,1)+1;
x(:,2) = x(:,2)-1;

x = [x; rand(100,3)];
x = [x; rand(100,3)+1];
x = [x; rand(100,3)-1];

goodness(1) = 0;
for numclust = 2:10
  for retry = 1:5
    [m,c] = kmeans(x,numclust);
    
    s(retry)=sum(silhouette(x,m));
  end
  goodness(numclust)=max(s);
end
  
numclust = find(goodness==max(goodness))

[m,c] = kmeans(x,numclust);
[e,d]= pca(c');
%[e,d]= pca(x');

x_pc = x*e;

figure(1);

colour = 'bgrcmykbgrcymk';
for ii = 1:length(x);
  plot(x(ii,end),x(ii,end-1),['o' colour(m(ii))]);
  hold on;
end
hold off;


figure(2);
colour = 'bgrcmykbgrcmyk';
for ii = 1:length(x);
  plot(x_pc(ii,end),x_pc(ii,end-1),['o' colour(m(ii))]);
  hold on;
end
hold off;

figure(3);
