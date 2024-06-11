function optifft(cellid)

s=dbgetscellfile('cellid',cellid,'runclassid',12);
r=respload([s(1).path s(1).respfile]);
r(find(isnan(r)))=0;
r=r-mean(r(:));
plot(abs(fft(r)));
suptitle([cellid ' opti fft']);
