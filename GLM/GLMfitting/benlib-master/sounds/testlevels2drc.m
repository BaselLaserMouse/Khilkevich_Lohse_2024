%% test levels2drc against Neil's DRCs

stim.f_s = 24414*2; % floor(TDT50K)
stim.freq.min = 500;
stim.freq.step = 2^(1/6);
stim.freq.n = 34;

stim.chord_duration = 25/1000;
stim.ramp_duration = 5/1000;

%stim.meanlevel = 40;
%ranges = [10 30];

%% get frequencies of tones
stim.freq.multipliers = 0:(stim.freq.n-1);
stim.freq.freqs = stim.freq.min*stim.freq.step.^stim.freq.multipliers;

stim.freqs = stim.freq.freqs;

l = load('./test/grid.40Hz.gain_time_course.chord_fs.40.token.1.mat');
drc = levels2drc(stim.f_s, stim.freqs, l.grid, stim.chord_duration, stim.ramp_duration);

snd = drc.snd;

% figure(1);
% e = load('test/envelopes.mat');
% r = env(1:16:end);
% r = log10(r);
% plot(r/r(415));
% hold all;
% plot(e.env(end,:)/e.env(end,415));
% hold off;

figure(2);
t = 1:length(snd);
neil = f32read('test/gain_time_course.chord_fs.40.token.1.raw.f32')';

n = min(length(snd), length(neil))-500;
m = 1;

sn = snd/snd(476);
nn = neil/neil(476);
plot(t(m:n), sn(m:n));
hold all;
plot(t(m:n), nn(m:n)+3);
plot(t(m:n), sn(m:n)-nn(m:n)+6);
hold off;

d = max(abs(sn(1:n-100)-nn(1:n-100)));
