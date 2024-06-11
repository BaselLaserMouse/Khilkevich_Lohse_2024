function slownatplot(respfile,reps)

hz = 60;
ms = 1000/hz;

r = respload(respfile);
r = r';
r(find(isnan(r))) = 0;
r = r*hz;


len = 20;
times = -len:1:len;
goodav=zeros(1,length(times));
count = 0;
for frame = 1:reps:length(r)
  if (frame+min(times)>0)&(frame+max(times))<length(r)
    count = count + 1;
    goodav= goodav+r(frame+times);
  end
end

goodmn = goodav/count;

goodav=zeros(1,length(times));
count = 0;
for frame = 1:reps:length(r)
  if (frame+min(times)>0)&(frame+max(times))<length(r)
    count = count + 1;
    goodav= goodav+(r(frame+times)-goodmn).^2;;
  end
end

goodsem = ((goodav./count).^(1/2))/sqrt(count);

mn = floor(min(goodmn-goodsem))-1;
mx = ceil(max(goodmn+goodsem))+1;
h1 = errorbar(times*ms,goodmn,goodsem,'k');
xlabel('Time/ms');
ylabel('Mean firing rate/Hz');

fnd = findstr(respfile,'/');
fnd = fnd(end);
title(respfile(fnd+1:end));