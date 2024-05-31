function NIdaq_events_ses_path = extract_events_times_from_NI_data(NIbinName, NIbin_path, varargin)

ind_tmp = strfind(NIbinName, '_g0');
session_name = NIbinName(1:ind_tmp-1);
% Parse the corresponding metafile
meta = ReadMeta(NIbinName, NIbin_path);

[MN,MA,XA,DW] = ChannelCountsNI(meta);

NI_sample_rate = SampRate(meta);
nSamp = Inf;    %read full session
dataArray = ReadBin(0, nSamp, meta, NIbinName, NIbin_path);

dLineList = 0:7;    % read all digital lines
dw = 1;
digArray = ExtractDigital(dataArray, meta, dw, dLineList);

NIdaq_events.session_name = session_name;

[NIdaq_events.Synch.rise_t, NIdaq_events.Synch.fall_t, NIdaq_events.Synch.duration] = get_event_times_threshold(digArray(1, :), 'D', [], NI_sample_rate);

% camera identity is determined by the port number on NI breakout box to which the camera GPIO cable is connected. 
[NIdaq_events.Front_cam.rise_t, NIdaq_events.Front_cam.fall_t, NIdaq_events.Front_cam.duration] = get_event_times_threshold(digArray(2, :), 'D', [], NI_sample_rate);        
[NIdaq_events.Eye_cam.rise_t, NIdaq_events.Eye_cam.fall_t, NIdaq_events.Eye_cam.duration] = get_event_times_threshold(digArray(3, :), 'D', [], NI_sample_rate);
[NIdaq_events.Top_cam.rise_t, NIdaq_events.Top_cam.fall_t, NIdaq_events.Top_cam.duration] = get_event_times_threshold(digArray(4, :), 'D', [], NI_sample_rate);
% digital channels 5 and 8 are empty for now 
[NIdaq_events.Rot_enc_A.rise_t, NIdaq_events.Rot_enc_A.fall_t, NIdaq_events.Rot_enc_A.duration] = get_event_times_threshold(digArray(6, :), 'D', [], NI_sample_rate);
[NIdaq_events.Rot_enc_B.rise_t, NIdaq_events.Rot_enc_B.fall_t, NIdaq_events.Rot_enc_B.duration] = get_event_times_threshold(digArray(7, :), 'D', [], NI_sample_rate);

analog_chs = GainCorrectNI(dataArray(1:XA, :), 1:XA, meta);
threshold_gen = 1; %in V, use for step-wise event types
threshold_lick = 0.15;

if length(analog_chs(:,1))>=10 % with laser
    [NIdaq_events.Masking_ON.rise_t, NIdaq_events.Masking_ON.fall_t, NIdaq_events.Masking_ON.duration]  = get_event_times_threshold(analog_chs(2, :), 'A', threshold_gen, NI_sample_rate); % masking light
    [NIdaq_events.Laser_ON.rise_t, NIdaq_events.Laser_ON.fall_t, NIdaq_events.Laser_ON.duration]  = get_event_times_threshold(analog_chs(3, :), 'A', threshold_gen, NI_sample_rate);    %  laser 
    [NIdaq_events.Baseline_ON.rise_t, NIdaq_events.Baseline_ON.fall_t, NIdaq_events.Baseline_ON.duration]  = get_event_times_threshold(analog_chs(4, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Change_ON.rise_t, NIdaq_events.Change_ON.fall_t, NIdaq_events.Change_ON.duration]  = get_event_times_threshold(analog_chs(5, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Air_puff.rise_t, NIdaq_events.Air_puff.fall_t, NIdaq_events.Air_puff.duration]  = get_event_times_threshold(analog_chs(6, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Lick_L.rise_t, NIdaq_events.Lick_L.fall_t, NIdaq_events.Lick_L.duration]  = get_event_times_threshold(analog_chs(7, :), 'A', threshold_lick, NI_sample_rate);
    [NIdaq_events.Lick_R.rise_t, NIdaq_events.Lick_R.fall_t, NIdaq_events.Lick_R.duration]  = get_event_times_threshold(analog_chs(8, :), 'A', threshold_lick, NI_sample_rate);
    [NIdaq_events.Valve_L.rise_t, NIdaq_events.Valve_L.fall_t, NIdaq_events.Valve_L.duration]  = get_event_times_threshold(analog_chs(9, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Valve_R.rise_t, NIdaq_events.Valve_R.fall_t, NIdaq_events.Valve_R.duration]  = get_event_times_threshold(analog_chs(10, :), 'A', threshold_gen, NI_sample_rate);
else
    [NIdaq_events.Baseline_ON.rise_t, NIdaq_events.Baseline_ON.fall_t, NIdaq_events.Baseline_ON.duration]  = get_event_times_threshold(analog_chs(2, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Change_ON.rise_t, NIdaq_events.Change_ON.fall_t, NIdaq_events.Change_ON.duration]  = get_event_times_threshold(analog_chs(3, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Air_puff.rise_t, NIdaq_events.Air_puff.fall_t, NIdaq_events.Air_puff.duration]  = get_event_times_threshold(analog_chs(4, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Lick_L.rise_t, NIdaq_events.Lick_L.fall_t, NIdaq_events.Lick_L.duration]  = get_event_times_threshold(analog_chs(5, :), 'A', threshold_lick, NI_sample_rate);
    [NIdaq_events.Lick_R.rise_t, NIdaq_events.Lick_R.fall_t, NIdaq_events.Lick_R.duration]  = get_event_times_threshold(analog_chs(6, :), 'A', threshold_lick, NI_sample_rate);
    [NIdaq_events.Valve_L.rise_t, NIdaq_events.Valve_L.fall_t, NIdaq_events.Valve_L.duration]  = get_event_times_threshold(analog_chs(7, :), 'A', threshold_gen, NI_sample_rate);
    [NIdaq_events.Valve_R.rise_t, NIdaq_events.Valve_R.fall_t, NIdaq_events.Valve_R.duration]  = get_event_times_threshold(analog_chs(8, :), 'A', threshold_gen, NI_sample_rate);
end

% parse trials, check for weird changes in up/down states of analog signals, correct for fake events

Baseline_ON_old = NIdaq_events.Baseline_ON;
if length(Baseline_ON_old.rise_t)>length(Baseline_ON_old.fall_t)   % check for incompletely recorded trials
   full_tr_numb = length(Baseline_ON_old.duration);
   Baseline_ON_old.rise_t(full_tr_numb+1:end) = [];
   disp('Found incomplete trials!')
elseif length(Baseline_ON_old.rise_t)<length(Baseline_ON_old.fall_t)   % check for incompletely recorded trials
   full_tr_numb = length(Baseline_ON_old.rise_t);
   Baseline_ON_old.fall_t(full_tr_numb+1:end) = [];
  disp('Found incomplete trials!')
end

Baseline_ON_dur = Baseline_ON_old.duration;
ITI = Baseline_ON_old.rise_t(2:end) - Baseline_ON_old.fall_t(1:end-1);
splits_tr_ind = find(ITI<0.01); %typical duration of split is less than 1ms

splits_tr_count = 1;
Baseline_ON_new = [];
tr_old = 1;
tr_new = 1;
spits_count = 0;

while tr_old<=length(Baseline_ON_dur)
    if ~isempty( intersect(tr_old, splits_tr_ind) )     % on detected split
        
        step_size = 1;

        while ~isempty( intersect(tr_old + step_size, splits_tr_ind) )  % find how many adjacent splits are there to concatenate
            step_size = step_size + 1;
            spits_count = spits_count + 1;
        end
        
        spits_count = spits_count + 1;
        splits_tr_count = splits_tr_count + 1;
        Baseline_ON_new.rise_t(tr_new) = Baseline_ON_old.rise_t(tr_old);
        Baseline_ON_new.fall_t(tr_new) = Baseline_ON_old.fall_t(tr_old+step_size);
        Baseline_ON_new.duration(tr_new) = Baseline_ON_new.fall_t(tr_new) - Baseline_ON_new.rise_t(tr_new);
        tr_old = tr_old + step_size + 1;
    else
        Baseline_ON_new.rise_t(tr_new) = NIdaq_events.Baseline_ON.rise_t(tr_old);
        Baseline_ON_new.fall_t(tr_new) = NIdaq_events.Baseline_ON.fall_t(tr_old);
        Baseline_ON_new.duration(tr_new) = NIdaq_events.Baseline_ON.duration(tr_old);
        tr_old = tr_old + 1;
    end
    tr_new = tr_new + 1;
end

trials_numb = length(Baseline_ON_new.duration);
disp(['Corrected ' num2str(spits_count) ' BaselineON events'])
disp(['Expected number of trials: ' num2str(trials_numb)])    
NIdaq_events.Baseline_ON = Baseline_ON_new;

% Use cleaned Baseline_ON events to check other analog signal lines for splits too

[NIdaq_events.Change_ON, splits_numb] = fix_splits(NIdaq_events.Change_ON.rise_t,  NIdaq_events.Change_ON.fall_t, NIdaq_events.Baseline_ON.rise_t);
disp(['Corrected ' num2str(splits_numb) ' ChangeON events'])

[NIdaq_events.Air_puff, splits_numb] = fix_splits(NIdaq_events.Air_puff.rise_t,  NIdaq_events.Air_puff.fall_t, NIdaq_events.Baseline_ON.rise_t);
disp(['Corrected ' num2str(splits_numb) ' Air_puff events'])

[NIdaq_events.Valve_L, splits_numb] = fix_splits(NIdaq_events.Valve_L.rise_t,  NIdaq_events.Valve_L.fall_t, NIdaq_events.Baseline_ON.rise_t);
disp(['Corrected ' num2str(splits_numb) ' Reward Valve_L events'])

[NIdaq_events.Valve_R, splits_numb] = fix_splits(NIdaq_events.Valve_R.rise_t,  NIdaq_events.Valve_R.fall_t, NIdaq_events.Baseline_ON.rise_t);
disp(['Corrected ' num2str(splits_numb) ' Reward Valve_R events'])

% sanity checks
ITI = Baseline_ON_new.rise_t(2:end) - Baseline_ON_new.fall_t(1:end-1);
if min(ITI) < 3
    disp('Warning: found ITI < 3 s')
end

if nanmin(NIdaq_events.Change_ON.rise_t - Baseline_ON_new.rise_t) < 0
    disp('Warning: found ChangeON earlier than BaselineON')
end
    
% get frame times from photodiode signal

photodiode_ch = analog_chs(1, :); 
Baseline_ON_smpl_ind = round(NI_sample_rate * NIdaq_events.Baseline_ON.rise_t);
t = (1:length(photodiode_ch))/NI_sample_rate;

for tr = 1:length(Baseline_ON_smpl_ind)             % get readings of high/low states in photodiode 
    photodiode_pre_trial_mean(tr) = mean( photodiode_ch( Baseline_ON_smpl_ind(tr) - round(NI_sample_rate) : Baseline_ON_smpl_ind(tr)) );    % use 1s before trial start
    photodiode_trial_sorted = sort( photodiode_ch( Baseline_ON_smpl_ind(tr) : Baseline_ON_smpl_ind(tr)  + round(NI_sample_rate)), 'descend' );  % first 1 s during the trial
    photodiode_trial_high(tr) = mean(photodiode_trial_sorted(1:10));
    photodiode_trial_low(tr) = mean(photodiode_trial_sorted(end-10:end));
end

if (max(photodiode_pre_trial_mean)>min(photodiode_trial_high)) || ( min(photodiode_pre_trial_mean)<max(photodiode_trial_low) )  % check if photodiode signal is consistent and usable 
    disp('Suspicious changes in photodiode signal (ok is fsm_gui was restarted during the session) ')    
end

try
    % find local maxima in photodiode trace
    [~, up_state_times] = findpeaks(photodiode_ch, t, 'MinPeakProminence', (median(photodiode_trial_high)- mean(photodiode_pre_trial_mean) - 0.1), 'MinPeakDistance', 0.01, 'MinPeakHeight', 1); % orignal 

    % find local minima in photodiode trace
    inv_photodiode_ch_zero_mean = -(photodiode_ch - mean(photodiode_pre_trial_mean) );
   [~, low_state_times] = findpeaks( inv_photodiode_ch_zero_mean, t, 'MinPeakProminence', mean(photodiode_pre_trial_mean) - (median(photodiode_trial_low)-0.1), 'MinPeakDistance', 0.01, 'MinPeakHeight', 1); % original  

catch
   disp('Bad photodiode signal :(') 
   up_state_times = [];
   low_state_times = [];
end

frame_times_tot = [up_state_times low_state_times];
frame_times_tot = sort(frame_times_tot);    % these are frame offset times
IFI = diff(frame_times_tot);
IFI(IFI>0.5) = [];
IFI = median(IFI);

% parse frame times per trial
frames_per_tr = [];
for tr = 1:trials_numb

    tr_start_time = NIdaq_events.Baseline_ON.rise_t(tr) - 0.5;  % 0.5s just to be safe 
    
    tr_end_time = NIdaq_events.Change_ON.fall_t(tr) + 0.5; 
    if isnan(tr_end_time) % no Change event
        tr_end_time = NIdaq_events.Baseline_ON.fall_t(tr) + 0.5; 
    end

    frame_times_tr = frame_times_tot( find( (frame_times_tot>=tr_start_time)&(frame_times_tot<=tr_end_time) )); 
    try
        frame_times_tr = [ (frame_times_tr(1) - IFI)   frame_times_tr(1:end-1)];    % shifting from frame offset times to onset times
    catch
        frame_times_tr = [];
        disp(['No frames on trial ' num2str(tr) '?'])
    end
    frames_per_tr.time{1, tr} = frame_times_tr;
    frames_per_tr.delayed_frames_numb(1, tr) = sum( diff(frame_times_tr)>(1.1*IFI));  
end
NIdaq_events.frame_times_tr = frames_per_tr;

if isempty(varargin)
    save_path = 'D:\NIdaq_events_data';
else
    save_path = varargin{1};
end

save(fullfile(save_path, [session_name '_NIdaq_events.mat']), 'NIdaq_events');
NIdaq_events_ses_path = fullfile('D:\NIdaq_events_data', [session_name '_NIdaq_events.mat']);

end
    
    











