function [outt,oute] = findevents(record,eventname)
% function [outt,oute] = findevents(record,eventname)
%
% wildcard-matches events in a p2m record and
% returns the times and event names

int = record.ev_t;
ine = record.ev_e;

outt = [];
oute = [];

ctr = 0;
for ii = 1:length(ine)
  if strcmpwild(ine{ii},eventname)
    ctr = ctr + 1;
    outt(ctr) = int(ii);
    oute{ctr} = ine{ii};
  end
end
