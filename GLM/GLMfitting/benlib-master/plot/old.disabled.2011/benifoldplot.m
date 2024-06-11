function benifoldplot(net,inputs,outputs,filtermat,varargin)
%function benifoldplot(net,inputs,outputs,filtermat,varargin)
%
%This function takes a network, it's inputs and outputs, and
%options, and plots the dimensions in the desired rotation as
%well as the responses along these dimensions
%
%
%net: a network
%
%inputs: a net.nin X m matrix of inputs to the network
%
%outputs: a 1 X m vector of the corresponding outputs
%


for ii=1:size(varargin,2)
  if isstr(varargin{ii})
	if strcmp(varargin{ii},'dimnum')
	  dimnum=varargin{ii+1};
	elseif strcmp(varargin{ii},'filename')
	  filename=varargin{ii+1};
        elseif strcmp(varargin{ii},'disp')
	  dispflag=varargin{ii+1};
        elseif strcmp(varargin{ii},'nbins')
	  nbins=varargin{ii+1};
        end
  end
end

if ~exist('nbins','var')
   nbins=20;
end

if ~exist('dispflag','var')
   dispflag='vo';
else
   if strcmp(dispflag(1),'a')
      net.auditory=1;
   end
end

v=eye(net.nin);

if exist('dimnum','var')
  v=v(:,dimnum);
  unitsmax=1;
else
  unitsmax=size(v,2);
end
unitsmin=1;
proj=v'*inputs;
maxx=max(proj')';
minn=min(proj')';

%FIND VARIANCES FOR RED AND GREEN CURVES
%------------------------------------------------------------------
[bin,binmeans]=histbin(proj,round(size(proj,2)/nbins));
numbin=max(max(bin));

for ii=1:unitsmax
for jj=1:numbin
  [y(ii,jj),err(ii,jj)]=bootstrap(outputs(find(bin(ii,:)==jj))');
  qq(ii,jj)=mean(mlpfwd(net,inputs(:,find(bin(ii,:)==jj))'));
end
end

minn=binmeans(:,1);
maxx=binmeans(:,end);

%FIND BLUE CURVE
%-------------------------------------------------------------------
for ii=unitsmin:unitsmax
   x(ii,:)=mlpfwd(net,(linspace(minn(ii,1),maxx(ii,1),100)'*v(:,ii)'))';
   %x(ii,:)=mlpfwd(net,(linspace(binmeans(ii,1),binmeans(ii,end),100)'*v(:,ii)'))';
end
%------------------------------------------------------------------

  y=y*16.7;
  err=err*16.7;
  x=x*16.7;
  qq=qq*16.7;
  outputs=outputs*16.7;

%MAKE PLOTS
%-----------------------------------------------------------------
for ii=1:unitsmax
  figure;
  fignum=gcf;

%Dimensions at the top
%---------------------------
  sx=size(filtermat,1);
  sy=size(filtermat,2);
  st=size(filtermat,3);
  A(1:sx,1:sy,1,1:st)=filtermat(:,:,end:-1:1,ii);
  climax=max(max(max(max(abs(A)))));
  clim=[-climax climax];
  plotter(-A,'coor',[.05,.65,.43,.23],'clim',clim);
  plotter(A,'coor',[.55,.65,.43,.23],'clim',clim);
  subplot('position',[0.13 0.05 0.775 0.6]);
  hold on

%The three curves
%------------------------
  errorshade(binmeans(ii,:),y(ii,:),err(ii,:),[.75 .75 .75],[.75 .75 .75]);
  hand=plot(linspace(minn(ii,1),maxx(ii,1),100),x(ii,:)');
  set(hand,'linewidth',3);
  hand=plot(binmeans(ii,:),qq(ii,:),'k');
  set(hand,'linewidth',3);

%Mean firing rate
%---------------------------
  plot(linspace(minn(ii,1),minn(ii,1)+(maxx(ii,1)-minn(ii,1))/15,3),mean(outputs)*ones(1,3),'k')
  plot(linspace(maxx(ii,1)-(maxx(ii,1)-minn(ii,1))/15,maxx(ii,1),3),mean(outputs)*ones(1,3),'k')

  hand=ylabel('Spikes/Second');
  set(hand,'fontsize',14,'fontweight','bold');
  hold off
  set(gca,'fontsize',14,'fontweight','bold');
%SAVE PLOT TO FILE IF FILENAME IS SPECIFIED
%----------------------------------------------------------------------
  if exist('filename')
    orient landscape
    saveas(gcf,[filename cell '-' vecspace '-' num2str(ii,'%.3d')],'psc')
    clf
  end
end

