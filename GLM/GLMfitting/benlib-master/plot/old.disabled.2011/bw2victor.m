function ok = bw2victor(bwfile)

curDir = pwd;
[pathstr, name, ext, versn] = fileparts(bwfile);
cd(pathstr);
fulldir=pwd;
cd(curDir); % get back to where you were
bwfile = [fulldir '/' name ext];
load(bwfile);

fn = strsplit(bwfile,'.');

stadfile = fopen([fn{1} '.stad'],'w');
stamfile = fopen([fn{1} '.stam'],'w');

fprintf(stamfile,['datafile=' fulldir '/' name '.stad;\n']);
fprintf(stamfile,['site=1; ']);
fprintf(stamfile,['label=unit001; ']);
fprintf(stamfile,['recording_tag=episodic; ']);
fprintf(stamfile,['time_scale=1.000000; ']);
fprintf(stamfile,['time_resolution=0.001000;\n']);

% category labels
for ii = 1:length(data.set)
  fprintf(stamfile,['category=' num2str(ii) '; label= ' num2str(ii) ';\n']);
end

% sweeps
%keyboard;
count = 0;
for ii = 1:length(data.set)
  for jj = 1:length(data.set(ii).repeats)
    count = count + 1;
    fprintf(stamfile,['trace=' num2str(count) '; ']);
    fprintf(stamfile,['catid=' num2str(ii) '; ']);
    fprintf(stamfile,['trialid=' num2str(jj) '; ']);
    fprintf(stamfile,['siteid=' num2str(1) '; ']);
    fprintf(stamfile,['start_time=' num2str(0.000000) '; ']);
    fprintf(stamfile,['end_time=' num2str(data.metadata.sweeplength) '; \n']);

    line = '';
    for kk = 1:length(data.set(ii).repeats(jj).t)
      line = [line num2str(data.set(ii).repeats(jj).t(kk)) ' '];
    end
    fprintf(stadfile,[line(1:end-1) '\n']);
  end
end

fclose(stadfile);
fclose(stamfile);
ok = 1;
%keyboard