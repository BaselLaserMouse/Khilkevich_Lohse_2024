function firing_rate = calc_firing_rate(spikes, sigma, smooth, one_or_two_sided_gaussian)
%UNTITLED Summary of this function goes here
%   assumes that spikes has dimentions of TrialsXTime


trials_num = length(spikes(:, 1));
duration = length(spikes(1, :));

if smooth == 1
    gauss_hw = 4*sigma;
    x = -gauss_hw:gauss_hw;
    
    if one_or_two_sided_gaussian == 1
        gauss_window = [ 2*normpdf(x(1:gauss_hw), 0, sigma) zeros(1, gauss_hw)];             % half-gaussian to estimate firing rate
    else
        if one_or_two_sided_gaussian == 2
            gauss_window = normpdf(x, 0, sigma);             % full gaussian to estimate firing rate
        end
    end
end

firing_rate = zeros(trials_num, duration);

for tr = 1:trials_num
    spike_times = find(spikes(tr,:)==1);
    ISI = diff(spike_times);        % inter-spike intervals
    
    firing_rate_proxy = zeros(1, duration);

    if ~isempty(ISI)
        firing_rate_proxy(1:spike_times(1)) = 1./(ISI(1)/1000);

        for i = 1:length(spike_times)-1
            firing_rate_proxy(spike_times(i)+1:spike_times(i+1)) = 1/(ISI(i)/1000);
        end

        firing_rate_proxy(spike_times(end)+1:duration) = 1/(ISI(end)/1000);
    end
    
    if smooth==1
%         firing_rate(tr, :) = firing_rate_proxy;
%         firing_rate(tr, 1+gauss_hw:end-gauss_hw) = conv(firing_rate_proxy, gauss_window, 'valid');    
%         firing_rate(tr, 1:gauss_hw) = firing_rate_proxy(1:gauss_hw);
%         firing_rate(tr, end-gauss_hw:end) = firing_rate_proxy(end-gauss_hw:end);

        firing_rate(tr, :) = conv(firing_rate_proxy, gauss_window, 'same');    

    else
        firing_rate(tr, :) = firing_rate_proxy;
    end
end

end

