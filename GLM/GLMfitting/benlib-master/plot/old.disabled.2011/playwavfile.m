function playwavfile(filename)
% function playwavfile(filename)
%  use mplayer to play a wav file
%  bw jan 2007
  
[y,fs,bits] = wavread(filename);
playsound(y,fs,bits);


