function subset = selectsmdata(data,paramname,values,valuesarelimits)

if ~exist('valuesarelimits','var')
  valuesarelimits =0;
end

if valuesarelimits
  if length(values)~=2
    disp('Need 2 limiting values');
    subset = [];
    return;
  end
else
  if ~iscell(values)
    values = {values};
  end
end

subset = emptystructwithstructure(data);
subset(1).metadata = data.metadata;
subset.set = emptystructwithstructure(data.set);

for ii = 1:length(data.set)
  thisset = data.set(ii);
  f = getfield(thisset.stim_params,paramname);
  match = 0;
  if valuesarelimits
    if (f>=values(1)) && (f<=values(2))
      match = 1;
    end
  else
    for jj = 1:length(values)
      if (f==values{jj})
        match = 1;
      end
    end
  end
  if (match==1)
    subset.set(end+1) = thisset;
  end
end
