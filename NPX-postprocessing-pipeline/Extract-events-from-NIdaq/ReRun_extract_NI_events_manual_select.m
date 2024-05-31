function ReRun_extract_NI_events_manual_select

    cd('F:\Andrei');
    % Ask user for binary file
    [binName, path] = uigetfile('*.bin', 'Select Binary File');
    extract_events_times_from_NI_data(binName, path);
    
end