function [handle, colorbarHandle] = j_specgram(s,sr,show_colorbar)

if nargin==2
    show_colorbar=1;
end

win = round(.02*sr);
noverlap = round(win/2);
[S,F,T] = spectrogram(s,win,noverlap,[],sr);
min_t = floor(min(T));
%max_t = floor(max(T));

F = F/1000; % for display only, gets rid of x10^4 on y axis
max_t = max(T);
min_f = floor(min(F));
max_f = floor(max(F));

A = abs(S);
handle = surf(T,F,20*log10(A/max(max(A))));
shading flat;view(0,90);
%invgray = flipud(gray);
%colormap(invgray);set(gca,'CLim',[-50 0]);
if show_colorbar
    colorbarHandle = colorbar;
else
	colorbarHandle = nan;
end
set(gca,'XLim', [min_t max_t]);
set(gca,'YLim', [min_f max_f]);
ylabel('Frequency (kHz)')
xlabel('Time (sec)')