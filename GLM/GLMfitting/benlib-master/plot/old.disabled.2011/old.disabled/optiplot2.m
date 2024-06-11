function optiplot2(indexfile,respfile)

% hardcoded! fixme!
hz = 60;
ms = 1/hz*1000;

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

order = zeros(0,2);
while instr~=-1
  id = eval(instr(fnd_und+1:fnd_dot-1));
  fnd_spc = findstr(instr,' ');
  fnd_spc = fnd_spc(end);
  fr      = eval(instr(fnd_spc+1:end));
  order(end+1,:) = [id fr];
  instr = fgets(h);
end

fclose(h);  

sm = cumsum(order(:,2));
order(1,2)     = 1;
order(end+1,1) = -1;
order(2:end,2) = sm(1:end);

raster = zeros(1,max(order(:,2)))+nan;
for ii = 1:length(order(:,1))
  raster(order(ii,2)) = order(ii,1);
end

r = respload(respfile);
r = r';
%r(find(isnan(r))) = 0;
r = r*hz;

good = find(mod(raster,2)==1);
bad  = find(mod(raster,2)==0);

goodav=[];
len = 20;
times = -len/4:1:len;

for frame = good
  if (frame+min(times)>0)&(frame+max(times))<length(r)
    goodav= [goodav;r(frame+times)];
  end
end


goodmn = nanmean(goodav);
goodsem = nanstd(goodav)/sqrt(size(goodav,1));

badav =[];
for frame = bad
  if (frame+min(times)>0)&(frame+max(times))<length(r)
    badav= [badav;r(frame+times)];
  end
end


badmn = nanmean(badav);
badsem = nanstd(badav)/sqrt(size(badav,1));

allav = [badav;goodav];
allmn = nanmean(allav);
allsem = nanstd(allav)/sqrt(size(allav,1));

mn = floor(min([allmn-allsem,goodmn-goodsem,badmn-badsem]))-1;
mx = ceil(max([allmn+allsem,goodmn+goodsem,badmn+badsem]))+1;
%clf;
%p = patch([0 8 8 0],[mn mn mx mx],[0.7, 0.7, 0.7]);
%set(p,'EdgeColor',[0.7,0.7,0.7]);
h1 = errorbar(times*ms,goodmn,goodsem,'g--');
hold on;
h2 = errorbar(times*ms,badmn,badsem,'r-.');
h3 = errorbar(times*ms,allmn,allsem,'b:');
h4 = line([0 0],[mn mx]);
set(h4,'Color',[0 0 0]);
%t = min(times):0.01:max(times);
%h4 = plot(t*ms,mod(floor(t/8),2)+mx,'b');
hold off;
xlabel('Time/ms');
ylabel('Mean firing rate/Hz');
legend([h1(2),h2(2),h3(2)],{'Good';'Bad';'All'});

fnd = findstr(respfile,'/');
fnd = fnd(end);
title([respfile(fnd+1:end) '; ' indexfile]);
