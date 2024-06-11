function y = puretone(fs, freq, amp,len)

%fs = 44100;
t = 0:1/fs:len;
snd = amp*sin(2*pi*freq*t);

fr = 1/0.005;
t = 0:1/fs:.5/fr;
ramp = 0.5-0.5*cos(2*pi*fr*t);
snd(1:length(ramp)) = snd(1:length(ramp)) .*ramp;
snd(end:-1:end-length(ramp)+1) = snd(end:-1:end-length(ramp)+1).*ramp;
y = snd;
%keyboard;
%plot(snd);
%sound(snd,fs);