function tsf = pfft2fft(H)
% convert a pfft kernel to standard FFT
% i don't understand it, either. it's cobbled together from
% showkern.m
% bw may 2004

phasecount = 1;

spacebincount=size(H,1);
tbincount=size(H,2);
kcount=size(H,3);

chancount=spacebincount/phasecount;
Xmax=sqrt(chancount*2);
[cfilt,cfiltconj,cmask,cmaskconj]=gencfilt(Xmax,Xmax);

% don't average over phase
phx=ceil(sqrt(phasecount));
phy=ceil(phasecount/phx);

tsf=zeros(Xmax*Xmax,tbincount,kcount,phx*phy);
for ii=1:phasecount,
  tsf(cfilt,:,:,ii)=H((1:chancount)+(ii-1)*chancount,:,:);
end
tsf(cfiltconj,:,:,:)=tsf(cfilt,:,:,:);

tsf=reshape(tsf,Xmax,Xmax,tbincount,kcount,phx,phy);

tsf=reshape(permute(tsf,[1 5 2 6 3 4]),...
	    Xmax*phx,Xmax*phy,tbincount,kcount);