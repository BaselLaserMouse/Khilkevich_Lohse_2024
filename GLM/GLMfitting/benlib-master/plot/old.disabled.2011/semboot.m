function sem = semboot(data,nboot)

if ~exist('nboot','var')
  nboot = 1000;
end

if size(data,2)>1
  if size(data,1)==1
    data = data';
  else
    sem = zeros(1,size(data,2));
    for ii = 1:size(data,2)
      sem(ii) = semboot(data(:,ii),nboot);
    end
  end
else
  idx = ceil(rand(length(data),nboot)*length(data));
  bootdata = data(idx);
  m = median(bootdata);
  sem = std(m);
end
