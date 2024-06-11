function pyplextst(p2mfile,xlsfile)

pf  = p2mLoad(p2mfile);
plx = xlsread(xlsfile);

% plexon files are in sec, not ms
plx = plx*1000;

for ii = 1:length(pf.rec)
  numspikes_p2m = length(pf.rec(ii).spike_times);
  
  p2m_start_time = findevents(pf.rec(ii),'eye_start');
  p2m_end_time   = findevents(pf.rec(ii),'eye_stop');

  plx_start_time = p2m_start_time + plx(ii,2);
  plx_end_time   = p2m_end_time   + plx(ii,2);
  
  plx_spikes = plx(:,1);
  plx_spikes = plx_spikes(find((plx_spikes>plx_start_time)& ...
			       (plx_spikes<plx_end_time)));
  plx_spikes = plx_spikes - plx_start_time+p2m_start_time;
  numspikes_plx = length(plx_spikes);
  plot(pf.rec(ii).eyet,pf.rec(ii).raw_spike);
  hold on;
  plot(pf.rec(ii).spike_times,2250,'o');
  plot(plx_spikes,2200,'o');
  hold off;
  fprintf(['Trial ' num2str(ii) ': p2m spikes=' num2str(numspikes_p2m) ...
	   ' plx spikes=' num2str(numspikes_plx) '\n']);
  pause;
end


