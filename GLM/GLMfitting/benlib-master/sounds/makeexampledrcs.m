f_s = 44100;
freqs =  logspace(log10(500),log10(32000),31);

chord_duration = 25/1000;
ramp_duration = 2.5/1000;
stimlen = 10;
levels = (rand(31, stimlen/chord_duration)*2-1)*15+40;
drc_lo = levels2drc(f_s, freqs, levels, chord_duration, ramp_duration)
wavwrite(drc_lo.snd, f_s, 24, 'drc_lo.wav');

levels = (rand(31, stimlen/chord_duration)*2-1)*30+40;
drc_hi = levels2drc(f_s, freqs, levels, chord_duration, ramp_duration)
wavwrite(drc_hi.snd, f_s, 24, 'drc_hi.wav');
