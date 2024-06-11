function cost = gauss1dcost(params,x,y)

A = params(1);
m = params(2);
s = params(3);

g = gauss1d(A,m,s,x);

%figure(1);
%plot(g);axis([1 11 0 20]);drawnow;

cost = sum((y-g).^2);
