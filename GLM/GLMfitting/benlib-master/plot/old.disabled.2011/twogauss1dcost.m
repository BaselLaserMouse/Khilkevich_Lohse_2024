function cost = twogauss1dcost(params,x,y)

A = params(1);
m = params(2);
s = params(3);
A2= params(4);
m2= params(5);
s2= params(6);

g= gauss1d(A,m,s,x) + gauss1d(A2,m2,s2,x);

%figure(1);
%plot(g);axis([1 11 0 20]);drawnow;

cost = sum((y-g).^2);
