function optiplot2bw(indexfile,respfile)

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
r(end+1:end+50) = 0;
r(find(isnan(r))) = 0;
r = r*16.6;

%good = find(order==1);
%bad  = find(order~=1);
%keyboard;
good = find(mod(order,2)==1);
bad  = find(mod(order,2)==0);

len = 30;
goodav = zeros(0,len);
count = 0;
for ii = good
  count = count + 1
  frame = (ii-1)*8+1;
  goodav(count,:) = r(frame:frame+len-1);
end
size(goodav)
goodmn = mean(goodav);
goodsem = std(goodav)/sqrt(size(goodav,1));

badav = zeros(0,len);
count = 0;
for ii = bad
  count = count + 1;
  frame = (ii-1)*8+1;
  badav(count,:) = r(frame:frame+len-1);
end
size(badav)
badmn = mean(badav);
badsem = std(badav)/sqrt(size(badav,1));

allav = [badav;goodav];
allmn = mean(allav);
allsem = std(allav)/sqrt(size(allav,1));

h1 = errorbar(goodmn,goodsem,'g');
hold on;
h2 = errorbar(badmn,badsem,'r');
h3 = errorbar(allmn,allsem,'b');
hold off;
xlabel('Time/frames');
ylabel('Mean firing rate/Hz');
legend([h1(1),h2(1),h3(1)],{'Good';'Bad';'All'});
