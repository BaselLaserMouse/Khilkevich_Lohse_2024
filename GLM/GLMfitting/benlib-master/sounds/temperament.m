% equal temperament

f_eq = logspace(log10(440),log10(880),13);

% just intonation
f_ji = 440*[1 16/15 9/8 6/5 5/4 4/3 7/5 3/2 8/5 5/3 7/4 15/8 2/1];


%for ii = 1:length(f_eq)
%  puretone(f(ii),1,.25);
%end



%% equal temperament major scale
d = [0 2 2 1 2 2 2 1 ];
mj = cumsum(d)+1;
f_mj_eq = f_eq(mj);

for ii = 1:length(f_mj_eq)
  puretone(f_mj_eq(ii),1,.25);
end

% just intonation major scale
f_mj_ji = f_ji(mj);

for ii = 1:length(f_mj_ji)
  puretone(f_mj_ji(ii),.5,.25);
end

%% equal temperament tritone
d = [0 6];
tt = cumsum(d)+1;
f_tt_eq = f_eq(tt);

for ii = 1:length(f_tt_eq)
  puretone(f_tt_eq(ii),1,.25);
end

% ji tritone
