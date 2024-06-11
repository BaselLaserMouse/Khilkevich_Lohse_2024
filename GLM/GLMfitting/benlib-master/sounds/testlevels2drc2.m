% %% test levels2drc against Neil's DRCs

% stim.f_s = 24414*2; % floor(TDT50K)
% stim.freq.min = 500;
% stim.freq.step = 2^(1/6);
% stim.freq.n = 34;

% stim.chord_duration = 25/1000;
% stim.ramp_duration = 5/1000;

% %stim.meanlevel = 40;
% %ranges = [10 30];

% %% get frequencies of tones
% stim.freq.multipliers = 0:(stim.freq.n-1);
% stim.freq.freqs = stim.freq.min*stim.freq.step.^stim.freq.multipliers;

% stim.freqs = stim.freq.freqs;

% l = load('/Volumes/External/projects/mouse.drcs/test/grid.40Hz.gain_time_course.chord_fs.40.token.1.mat');

% grid_lo = (rand(size(l.grid))-.5)*10+40;
% grid_hi = (grid_lo-40)*2+40;

% drc_lo = levels2drc(stim.f_s, stim.freqs, grid_lo, stim.chord_duration, stim.ramp_duration);
% drc_hi = levels2drc(stim.f_s, stim.freqs, grid_hi, stim.chord_duration, stim.ramp_duration);

% level_lo = 94+20*log10(rms(drc_lo.snd))
% level_hi = 94+20*log10(rms(drc_hi.snd))

% level_hi-level_lo

t = 1:length(snd);
neil = f32read('test/gain_time_course.chord_fs.40.token.1.raw.f32')';

close all
win=1:441 % 10 ms window
i=0

for t=0:441:length(neil)-441
    clear w
    i=i+1;
    winRun=win+t;

    w=neil(winRun);

    RMS = sqrt(mean(w.^2));
    est_level=94+(20*log10(RMS));
    LevRun(i)=(est_level);
end

plot(LevRun,'r','linewidth',2)
