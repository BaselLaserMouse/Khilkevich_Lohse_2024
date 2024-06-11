function optiplot2(indexfile,respfile)

hz = 60;

h = fopen(indexfile,'r');

firstimage = 0;
while ~firstimage
  instr = fgets(h);
  if strcmp(instr(1:5),'image')
    firstimage = 1;
  end
end

fnd_und = findstr(instr,'_');
fnd_und = fnd_und(1);
fnd_dot = findstr(instr,'.');
fnd_dot = fnd_dot(1);

order = [];
while instr~=-1
  order(end+1) = eval(instr(fnd_und+1:fnd_dot-1));
  instr = fgets(h);
end

fclose(h);  

r = respload(respfile);
r = r';
r(find(isnan(r))) = 0;
r = r*16.6;

%good = find(order==1);
%bad  = find(order~=1);
%keyboard;
good = find(mod(order,2)==1);
bad  = find(mod(order,2)==0);


goodav=[];
len = 20;
times = -len:1:len;

for ii = good
  frame = (ii-1)*8+1;
  if (frame+min(times)>0)&(frame+max(times))<length(r)
    goodav= [goodav;r(frame+times)];
  end
end

size(goodav)
goodmn = mean(goodav);
goodsem = std(goodav)/sqrt(size(goodav,1));

badav =[];
for ii = bad
  frame = (ii-1)*8+1;
  if (frame+min(times)>0)&(frame+max(times))<length(r)
    badav= [badav;r(frame+times)];
  end
end

size(badav)
badmn = mean(badav);
badsem = std(badav)/sqrt(size(badav,1));

allav = [badav;goodav];
allmn = mean(allav);
allsem = std(allav)/sqrt(size(allav,1));

mn = floor(min([allmn-allsem,goodmn-goodsem,badmn-badsem]))-1;
mx = ceil(max([allmn+allsem,goodmn+goodsem,badmn+badsem]))+1;
clf;
%p = patch([0 8 8 0],[mn mn mx mx],[0.7, 0.7, 0.7]);
%set(p,'EdgeColor',[0.7,0.7,0.7]);
hold on;
h1 = errorbar(times*hz,goodmn,goodsem,'g--');
h2 = errorbar(times*hz,badmn,badsem,'r-.');
h3 = errorbar(times*hz,allmn,allsem,'b:');
t = min(times):0.01:max(times);
h4 = plot(t*hz,mod(floor(t/8),2)+mx);
hold off;
xlabel('Time/ms');
ylabel('Mean firing rate/Hz');
legend([h1(1),h2(1),h3(1)],{'Good';'Bad';'All'});

fnd = findstr(respfile,'/');
fnd = fnd(end);
title([respfile(fnd+1:end) '; ' indexfile]);
