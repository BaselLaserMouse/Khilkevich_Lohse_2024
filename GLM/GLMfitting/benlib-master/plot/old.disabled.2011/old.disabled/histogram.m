function p=histogram(data,nbins,colour,clear)

display=0;

if ~exist('nbins','var')
  nbins = 20;
end

if ~exist('colour','var')
  colour = [0 0 0.6];
end

if ~exist('clear','var')
  clear = 1;
end

if length(nbins)>1
  mn = nbins(1);
  mx = nbins(2);
  nbins = nbins(3);
else
  mn = min(data);
  mx = max(data);
end
rng = mx-mn;

edges = [mn:rng/(nbins):mx];
delta = max(abs(edges(1)),abs(edges(end)))*0.001;
histc_edges = edges+delta;
histc_edges(1) = histc_edges(1)-2*delta;

n = histc(data,histc_edges);

nbins = length(edges)-1;

if display
  fprintf([num2str(nbins) ' bins; ' num2str(sum(n)) ' data points\n']);
end

if clear
  cla;
end


for ii=1:nbins
    p=patch([edges(ii) edges(ii+1) edges(ii+1) edges(ii)],[0 0 n(ii) ...
		    n(ii)],[1 1 1]);

    if ~isstr(colour)
      set(p,'FaceColor',colour);
    end

end
