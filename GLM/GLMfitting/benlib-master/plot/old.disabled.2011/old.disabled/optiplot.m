function optiplot(fname,string)

psth = respload(fname,'psth');
r    = respload(fname,'r');

figure;
subplot(3,1,1);
r = compact_raster_matrix3(r);
plotrasterbw(r);
colormap(gray(256));
xlabel('Frame #');
ylabel('Trial #');

subplot(3,1,2);
plot(psth);
xlabel('Frame #');
ylabel('Firing rate (per frame)');

subplot(3,1,3);
f = abs(fft(psth));
plot([0:100],f(1:101));
xlabel('Temporal frequency');
ylabel('Power');

suptitle([fname '; ' string '; mean r=' num2str(nanmean(psth))]);