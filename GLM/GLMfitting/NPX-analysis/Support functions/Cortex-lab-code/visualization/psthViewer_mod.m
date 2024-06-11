

function psthViewer_mod(spikeTimes, clu, eventTimes, window, trial_type_names, tr_types, groups_numb)
% function psthViewer(spikeTimes, clu, eventTimes, window, tr_types)
%
% Controls:
% - c: dialog box to pick a new cluster ID number
% - t: toggle showing psth traces for each grouping variable or just the
% overall. If showing just overall, raster is sorted chronologically. If
% showing by grouping variable, raster is sorted by that variable.
% - r: select a new range within which to count spikes for the tuning curve
% -
%
% TODO:
% - if plotting all traces, color raster and sort
% - don't replot traces just change X,Y data for speed and for keeping zoom
% levels
% - indicate on tuning curve which color is which
% - add ability to switch from graded to distinguishable color scheme, also
% cyclical
% - add support for a second grouping variable - in that case, should use a
% different graded color scheme for each, overlay the traces in the tuning
% curve view, and also provide a 2-d image of tuning curve
% - add support for plot labels (traces in psth, x-axis in tuning curve)

fprintf(1, 'Controls:\n')
fprintf(1, '- left/right arrow: select previous/next cluster\n')
fprintf(1, '- up/down arrow: change smoothing of psth curves\n')
fprintf(1, '- c: dialog box to pick a new cluster ID number\n')
fprintf(1, '- t: toggle showing psth traces for each grouping variable or just the\n')
fprintf(1, 'overall. If showing just overall, raster is sorted chronologically. If\n')
fprintf(1, 'showing by grouping variable, raster is sorted by that variable.\n')
fprintf(1, '- r: select a new range within which to count spikes for the tuning curve\n')

params.smoothSize = 25; % in msec, stdev of gaussian smoothing filter
params.clusterIndex = 1;
params.rasterScale = 0; % height of ticks
params.window_plot = window;
params.window = [window(1) - 0.1, window(2) + 0.1];
params.showAllTraces = true;
params.showErrorShading = true;
params.startRange = window(1);
params.stopRange = window(2);
params.binSize = 0.001;

myData.spikeTimes = spikeTimes;
myData.clu = clu;

% if ~issorted(eventTimes)
%     [eventTimes, ii] = sort(eventTimes);
%     trGroups = trGroups(ii);
% end

myData.eventTimes = eventTimes;
myData.tr_types = tr_types;     % should be structured as a cell array, containing trial types for each group within each cell
myData.trial_type_names = trial_type_names;

myData.clusterIDs = unique(clu);
myData.plotAxes = [];
myData.groups_numb=groups_numb;

for g=1:groups_numb    
    myData.tr_type_labels{g} = unique(myData.tr_types{g});
    myData.tr_types_numb(g) = length( myData.tr_type_labels{g} );
%     if g>1
        params.colors{g} = copper(myData.tr_types_numb(g)); 
%     else
%         params.colors{g} = copper(ceil(myData.tr_types_numb(g)/2)); 
%         params.colors{g} = [params.colors{g} ; params.colors{g}];
%         params.colors{g}(7, :) = [];
%     end
end
% params.colors = params.colors(:, [3 2 1]);

myData.params = params;

f = figure;

set(f, 'UserData', myData);
set(f, 'KeyPressFcn', @(f,k)psthViewerCallback(f, k));

psthViewerPlot(f)
end

function psthViewerPlot(f)
% fprintf(1,'plot with fig %d\n', get(f,'Number'));
myData = get(f,'UserData');

% pick the right spikes
st = myData.spikeTimes(myData.clu==myData.clusterIDs(myData.params.clusterIndex));

for g=1:myData.groups_numb

    % compute everything, for each group of trials
    [psth, bins, rasterX, rasterY, spikeCounts, ba] = psthAndBA(st, myData.eventTimes{g}, myData.params.window, myData.params.binSize);
    trGroupLabels = myData.tr_type_labels{g};
    nGroups = myData.tr_types_numb(g);
    trial_type_names = myData.trial_type_names{g};
    % inclRange = bins>myData.params.startRange & bins<=myData.params.stopRange;
    % spikeCounts = sum(ba(:,inclRange),2)./(myData.params.stopRange-myData.params.startRange);

    % PSTH smoothing filter
    gw = gausswin(round(myData.params.smoothSize*6),3);
    smWin = gw./sum(gw);

    % smooth ba
    baSm = conv2(smWin,1,ba', 'same')'./myData.params.binSize;

    % construct psth(s) and smooth it
    if myData.params.showAllTraces
        psthSm = zeros(nGroups, numel(bins));
        if myData.params.showErrorShading
            stderr = zeros(nGroups, numel(bins));
        end
        for tr = 1:nGroups
            psthSm(tr,:) = mean(baSm(myData.tr_types{g}==trGroupLabels(tr),:));
            if myData.params.showErrorShading
                stderr(tr,:) = std(baSm)./sqrt(size(baSm,1));
            end
        end
    else

        psthSm = mean(baSm);
        if myData.params.showErrorShading
            stderr = std(baSm)./sqrt(size(baSm,1));
        end

    end

    % compute raster
    if myData.params.showAllTraces
        [~, inds] = sort(myData.tr_types{g});
        [tr,b] = find(ba(inds,:));
    else
        [tr,b] = find(ba);
    end
    [rasterX,yy] = rasterize(bins(b));
    rasterY = yy+reshape(repmat(tr',3,1),1,length(tr)*3); % yy is of the form [0 1 NaN 0 1 NaN...] so just need to add trial number to everything

    % scale the raster ticks
    rasterY(2:3:end) = rasterY(2:3:end)+myData.params.rasterScale;

    % % compute the tuning curve
    % tuningCurve = zeros(nGroups,2);
    % for g = 1:nGroups
    %     theseCounts = spikeCounts(myData.tr_types==trGroupLabels(g));
    %     tuningCurve(g,1) = mean(theseCounts);
    %     tuningCurve(g,2) = std(theseCounts)./sqrt(length(theseCounts));
    % end


    % Make plots

    % if isempty(myData.plotAxes)
        for p = 1:2
            if p==1
                subplot_ind = g;
            else
                subplot_ind = g+myData.groups_numb;
            end
            subplot(2, myData.groups_numb, subplot_ind);
            myData.plotAxes(g, p) = gca;
        end
    % end

    colors = myData.params.colors{g};
    % subplot(3,1,1);
    axes(myData.plotAxes(g, 1));
    hold off;
    max_fr=[];
    if myData.params.showAllTraces
        for tr = 1:nGroups
            plot(bins, psthSm(tr,:), 'Color', colors(tr,:), 'LineWidth', 2.0);
            max_fr(tr) = max(psthSm(tr,:));
            hold on;
        end
        legend(trial_type_names,'AutoUpdate','off')
        legend box off
        myData.max_fr(g) = max(max_fr);
    else
        plot(bins, psthSm);
    end
    xlim(myData.params.window_plot);
    title(['cluster ' num2str(myData.clusterIDs(myData.params.clusterIndex))]);
    xlabel('time (sec)');
    ylabel('firing rate (Hz)');
    yl = ylim();
    hold on;
%     plot(myData.params.startRange*[1 1], yl, 'k--');
%     plot(myData.params.stopRange*[1 1], yl, 'k--');
    makepretty;
    box off;

    % subplot(3,1,2);
    axes(myData.plotAxes(g, 2));
    hold off;
    plot(rasterX,rasterY, 'k');
    xlim(myData.params.window_plot);
    ylim([0 length(myData.eventTimes{g})+1]);
    ylabel('event number');
    xlabel('time (sec)');
    makepretty;
    box off;
end
    set(f, 'UserData', myData);
    
    for g = 1:3
        ciplot(zeros(1,2), ones(1,2)*max(myData.max_fr)*1.1, [0 1], 'b', 0.1, myData.plotAxes(g, 1));
        ylim(myData.plotAxes(g, 1), [0 max(myData.max_fr)*1.1])
    end

% % subplot(3,1,3);
% axes(myData.plotAxes(3));
% hold off;
% errorbar(trGroupLabels, tuningCurve(:,1), tuningCurve(:,2), 'o-');
% xlabel('grouping variable value');
% ylabel('average firing rate (Hz)');
% makepretty;
% box off;

% drawnow;

end

function psthViewerCallback(f, keydata)

% fprintf('callback on %d with source %d\n', f.Number, keydata.Source.Number);


updateOtherFigs = false;

myData = get(f, 'UserData');
% myData.params

switch keydata.Key
    case 'rightarrow' % increment cluster index
        
        myData.params.clusterIndex = myData.params.clusterIndex+1;
        if myData.params.clusterIndex>length(myData.clusterIDs)
            myData.params.clusterIndex=1;
        end
        updateOtherFigs = true;
        
    case 'leftarrow' % decrement cluster index
        
        myData.params.clusterIndex = myData.params.clusterIndex-1;
        if myData.params.clusterIndex<1
            myData.params.clusterIndex=length(myData.clusterIDs);
        end
        updateOtherFigs = true;
        
    case 'uparrow' % increase smoothing
        myData.params.smoothSize = myData.params.smoothSize*1.2;
        
    case 'downarrow' % decrease smoothing
        myData.params.smoothSize = myData.params.smoothSize/1.2;
        
    case 'e' % whether to show standard error as shading
        myData.params.showErrorShading = ~myData.params.showErrorShading;
        
    case 't' % whether to plot the psth trace for each condition or just the overall one
        myData.params.showAllTraces = ~myData.params.showAllTraces;
        updateOtherFigs = true;
        
    case 'r'
        ax = subplot(3,1,1); title('click start and stop of range')
        %         [startRange,~] = ginput();
        %         [stopRange,~] = ginput();
        waitforbuttonpress;
        q = get(ax, 'CurrentPoint');
        myData.params.startRange = q(1,1);
        waitforbuttonpress;
        q = get(ax, 'CurrentPoint');
        myData.params.stopRange = q(1,1);
        if myData.params.stopRange<myData.params.startRange
            tmp = myData.params.startRange;
            myData.params.startRange = myData.params.stopRange;
            myData.params.stopRange = tmp;
        end
        
    case 'c'
        newC = inputdlg('cluster ID?');
        ind = find(myData.clusterIDs==str2num(newC{1}),1);
        if ~isempty(ind)
            myData.params.clusterIndex = ind;
        end
        
        updateOtherFigs = true;
        
end

set(f, 'UserData', myData);

% plot with new settings
psthViewerPlot(f)

if updateOtherFigs && f==keydata.Source.Number && isfield(myData, 'otherFigs')
    % checking that the current figure matches the source number prevents
    % doing this when called *not* as the original fig
    setOtherFigsClusterIndex(myData, myData.params.clusterIndex)
    plotOtherFigs(f)
end

end


function setOtherFigsClusterIndex(myData, cInd)

for thatFig = myData.otherFigs
    thatData = get(thatFig, 'UserData');
    thatData.params.clusterIndex = cInd;
    set(thatFig, 'UserData', thatData);
    
end

end


function plotOtherFigs(f)
myData = get(f, 'UserData');
for thatFig = myData.otherFigs
%     thatFigFcn = get(thatFig, 'KeyPressFcn');
    figs = get(0, 'Children');
    figNumsCell = get(figs, 'Number');
    figNums = [figNumsCell{:}];
    thatFigObj = figs(figNums==thatFig);
    psthViewerPlot(thatFigObj);
end
figure(f) % return focus here
end

function makepretty()
% set some graphical attributes of the current axis

set(get(gca, 'XLabel'), 'FontSize', 17);
set(get(gca, 'YLabel'), 'FontSize', 17);
set(gca, 'FontSize', 13);

set(get(gca, 'Title'), 'FontSize', 20);

ch = get(gca, 'Children');

for c = 1:length(ch)
    thisChild = ch(c);
    if strcmp('line', get(thisChild, 'Type'))
        if strcmp('.', get(thisChild, 'Marker'))
            set(thisChild, 'MarkerSize', 15);
        end
        if strcmp('-', get(thisChild, 'LineStyle'))
            set(thisChild, 'LineWidth', 2.0);
        end
    end
end

end