function stim = twoSoundFilesVAS(snd1, az1, el1, level1, delay1, snd2, az2, el2, level2, delay2, ov2)

baseLevel = 80;

az1 = round(az1);
el1 = round(el1);
az2 = round(az2);
el2 = round(el2);



% add delay to first sound
delay1samp = round(delay1/1000*ov2.sampleRate);
delSnd1 = [zeros(delay1samp,1); snd1];

% apply VAS to first sound
[flt1, itd1] = getVASFilter(ov2, az1, el1);
vasSnd1 = applyVAS(delSnd1, flt1, itd1);

% scale sound
vasSnd1.L = vasSnd1.L*10^((level1-baseLevel)/20);
vasSnd1.R = vasSnd1.R*10^((level1-baseLevel)/20);



% add delay to second sound
delay2samp = round(delay2/1000*ov2.sampleRate);
delSnd2 = [zeros(delay2samp,1); snd2];

% apply VAS to second sound
[flt2, itd2] = getVASFilter(ov2, az2, el2);
vasSnd2 = applyVAS(delSnd2, flt2, itd2);

% scale sound
vasSnd2.L = vasSnd2.L*10^((level2-baseLevel)/20);
vasSnd2.R = vasSnd2.R*10^((level2-baseLevel)/20);



% superpose the two sounds
maxLen = max(length(vasSnd1.L), length(vasSnd2.L));
stim.L = zeros(maxLen, 1);
stim.L(1:length(vasSnd1.L)) = vasSnd1.L;
stim.L(1:length(vasSnd2.L)) = stim.L(1:length(vasSnd2.L)) + vasSnd2.L;

stim.R = zeros(maxLen, 1);
stim.R(1:length(vasSnd1.R)) = vasSnd1.R;
stim.R(1:length(vasSnd2.R)) = stim.R(1:length(vasSnd2.R)) + vasSnd2.R;
