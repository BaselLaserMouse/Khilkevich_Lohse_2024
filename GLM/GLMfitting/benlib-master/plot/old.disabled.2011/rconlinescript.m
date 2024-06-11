%function rconlinescript(cell,respnum,origpix,fmt,varargin)

function rconlinescript(cell,respnum,outsize,fmt,varargin)


d=['e' datestr(date,29)];

cellresp=[cell '.edrev3.' num2str(respnum,'%.3i')];
stimfile='/auto/fs2/willmore/matlab/stimuli/imsm/natrev2004.96.index60.1.pix16';
respfile=['/auto/fs1/willmore/ed_data/' d '/' cellresp];

if ~isempty(varargin)
  if strcmp(varargin,'opti')
    outputfile=['/auto/sal1/stim/opti/' d '/' cell '/' fmt];
    rconlinebw(respfile,stimfile,outsize,fmt,[],outputfile);
  end
else
  keyboard
  rconlinebw(respfile,stimfile,outsize,fmt);
end

