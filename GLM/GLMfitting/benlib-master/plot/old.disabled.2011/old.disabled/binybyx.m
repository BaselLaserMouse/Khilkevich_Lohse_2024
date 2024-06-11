function y_mn = binybyx(x,y)

bins = linspace(min(x),max(x),20)

y_mn = zeros(1,length(bins)-1);

for ii=1:length(bins)-1
  y_mn(ii) = mean( y(find((x>=bins(ii) & (x<bins(ii+1))))));
end

y = fminsearch(@(