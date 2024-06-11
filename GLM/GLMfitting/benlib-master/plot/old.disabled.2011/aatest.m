r = randn(10,1);
a = r*pi/8+pi/4;
l = 1-abs(r);
v = [cos(a).*l sin(a).*l];

for ii = 1:size(v,1)
  plot([0 v(ii,1)],[0 v(ii,2)]);
  hold on;
end
hold off;

%axis([0 max(v(:,1)) 0 max(v(:,2))]);

len = [];
dir = [];
for ii = 1:length(v)
  len(ii) = sqrt((v(ii,1)^2+v(ii,2)^2));
  dir(ii) = atan2(v(ii,2),v(ii,1));
end
