function trimsweeps(olddir,sweepstokeep)
% remove sweeps from .mat versions of brainware data

dir = [olddir '.trimmed'];
copyfile(olddir, dir);

files = lsbw2(dir);

for nfile = 1:length(files)
  fprintf([files{nfile} '\n']);
  load(files{nfile});
  
  for nset = 1:length(data.set)
    data.set(nset).repeats = data.set(nset).repeats(sweepstokeep);
    data.set(nset).spikes.t = [];
    data.set(nset).spikes.repeat_id = [];
    for nrep = 1:length(data.set(nset).repeats)
      data.set(nset).spikes.t = [data.set(nset).spikes.t data.set(nset).repeats(nrep).t];
      data.set(nset).spikes.repeat_id = [data.set(nset).spikes.repeat_id zeros(size(data.set(nset).repeats(nrep).t))+nrep];
    end
  end
  save(files{nfile},'data');
end
