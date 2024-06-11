function binnedwindow = get_binned_window(windowtype,length,binsize)
% function binnedwindow = get_binned_window(windowtype,length,binsize)
%
% Returns a (e.g. smoothing) window of the specified type and length that
% is resampled to the given binsize. The peak or symmetry of the window is
% preserved while resampling. This function acts as a wrapper for the
% MatLab function window() and allows to choose exponentially decaying
% functions.
%
% Inputs:
%   windowtype: Function handle as it would have been specified in window()
%               or 'exp0.123' wheras 0.123 represents the time constant tau
%               of an exponentially decaying function: 0.001s <= tau < 10s
%   length:     Duration of the window in seconds (not ms)
%   binsize:    Duration (size) of the sampling bins in seconds (not ms)
%
% Outputs:
%   binnedwindow: An array of values of which each represents the
%                 downsampled value fo the original window
%
% Example call: binnedwindow = get_binned_window(@hann,0.021,0.005);
%
% Written by: Oliver Schoppe, March 26 2014
% Last modified: Oliver Schoppe, April 08 2014

if(length<binsize),		error('The window cannot have a length smaller than the binsize!'); end
if(binsize<0.001),		error('The get_binned_window function is currently not designed to handle bins smaller than 1ms since its temporal resolution is set to 1ms. This could easily be changed.'); end
if(mod(length,0.001)),	warning('This function handles the window length only with a precision of 1ms.'); end

if(ischar(windowtype) && strfind(windowtype,'exp'))
    tau = str2num(strrep(windowtype,'exp',''));
    windowvalues = exp(-[0:length*1000]./(1000*tau));
    nrofbins = floor(length/binsize);
    binnedwindow = NaN(1,nrofbins);
    for bin=1:nrofbins
        binnedwindow(bin) = windowvalues((1000*binsize)*(bin-1)+1);
    end
else
    windowpoints = length*1000;
    windowvalues = window(windowtype,windowpoints);
    midpoint = ceil(windowpoints/2); % Bins will be centered around the midpoint
    % get biggest odd number of bins that fit into the window
    nrofbins = floor(length/binsize);
    if(~mod(nrofbins,2)), nrofbins = nrofbins - 1; end
    midbin = ceil(nrofbins/2);
    binnedwindow = NaN(1,nrofbins);
    for bin=1:nrofbins
        distancetomidpoint = 1000*binsize*(midbin-bin);
        binnedwindow(bin) = windowvalues(midpoint-distancetomidpoint);
    end
end

end