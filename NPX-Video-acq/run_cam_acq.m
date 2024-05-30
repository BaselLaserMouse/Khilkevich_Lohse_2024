function run_cam_acq(ses_state, cam_settings)

    handles.f = figure('Units','pixels', 'Position',[100 100 1700 800], 'Toolbar','figure');
    handles.start_cam_acq = uicontrol('Parent',handles.f,'Units','pixels','Style','pushbutton', 'Position',[50 720 150 50],'FontSize',12, 'String','Start recording', 'Callback', @start_cam_acq);
    handles.stop_cam_acq = uicontrol('Parent',handles.f,'Units','pixels','Style','pushbutton', 'Position',[50 660 150 50],'FontSize',12, 'String','Stop recording', 'Callback', @stop_cam_acq);
    handles.end_ses = uicontrol('Parent',handles.f,'Units','pixels','Style','pushbutton', 'Position',[50 600 150 50],'FontSize',12, 'String','Close GUI', 'Callback', @end_session);
    set(handles.f,'doublebuffer','off');
   
    cam_numb = cam_settings.cameras_number;
    draw_cam_axis_and_labels(220, 460, 384, cam_numb, 50)

    warning('off','spinnaker:propertySet');
    
    vidinp_obj_cam{1} = videoinput('mwspinnakerimaq',2,'Mono8_Mode1');      % create camera objects, front 
    vidinp_obj_cam{2} = videoinput('mwspinnakerimaq',1,'Mono8_Mode0');      % eye

    for cam_ind = 1:cam_numb
        vidinp_obj_cam{cam_ind}.LoggingMode = 'disk&memory';
        vidinp_obj_cam{cam_ind}.FramesPerTrigger = Inf;
        vidinp_obj_cam{cam_ind}.ReturnedColorSpace = 'grayscale';
        triggerconfig(vidinp_obj_cam{cam_ind}, 'immediate');
        vidinp_obj_cam{cam_ind}.UserData = cam_ind;

        vidinp_obj_cam{cam_ind}.StopFcn = @stop_strobe_out; 
        vidinp_obj_cam{cam_ind}.StartFcn = @start_strobe_out;
        
        if cam_settings.crop_eye_camera == 1
            if cam_ind == 2 % eye camera
                ROIPosition = vidinp_obj_cam{cam_ind}.ROIPosition;
                new_ROIPosition = [296 0 976 1024];
                set(vidinp_obj_cam{cam_ind}, 'ROIPosition', new_ROIPosition);
%                set(vidinp_obj_cam{cam_ind}, 'ROIPosition', ROIPosition);
            end
        end
        
        conf_obj_cam1{cam_ind} = getselectedsource(vidinp_obj_cam{cam_ind}); 
        conf_obj_cam1{cam_ind}.AcquisitionFrameRate = cam_settings.framerate{cam_ind}; 
        set(conf_obj_cam1{cam_ind}, 'LineSelector', 'Line2');  % GPIO2, configured as strobe output
        set(conf_obj_cam1{cam_ind}, 'LineSource', 'ExternalTriggerActive'); %initialize so that no strobe output is transmitted
        set(conf_obj_cam1{cam_ind}, 'LineInverter', 'True');  % set strobe output as rising edge of square pulse
        set(conf_obj_cam1{cam_ind}, 'StrobeDuration', 2000); % in us

        writer_obj_cam{cam_ind} = VideoWriter( fullfile(ses_state.video_save_path, [ses_state.session_name '_' cam_settings.cam_name{cam_ind} '_cam.mp4']), 'MPEG-4');
        writer_obj_cam{cam_ind}.FrameRate = conf_obj_cam1{cam_ind}.AcquisitionFrameRate;
        writer_obj_cam{cam_ind}.Quality = 100;
        vidinp_obj_cam{cam_ind}.DiskLogger = writer_obj_cam{cam_ind};
        
        open(writer_obj_cam{cam_ind});       
        frame = getsnapshot(vidinp_obj_cam{cam_ind});
        res = size(frame);
        disp([cam_settings.cam_name{cam_ind} ' camera: ' num2str(res(2)) ' by ' num2str(res(1)) ', ' num2str(writer_obj_cam{cam_ind}.FrameRate, '%.0f') ' FPS' ]);

        handles.current_frame_cam{cam_ind} = image(handles.cam_prev_ax{cam_ind}, zeros(size(frame), 'uint8'));
        preview(vidinp_obj_cam{cam_ind}, handles.current_frame_cam{cam_ind});

        if isfile(ses_state.metadata_path_and_name{cam_ind})    % shouldn't happen if session is named properly; mostly to remove test data
            delete(ses_state.metadata_path_and_name{cam_ind});
        end

        fid_met{cam_ind} = fopen(ses_state.metadata_path_and_name{cam_ind}, 'a');
        fprintf(fid_met{cam_ind}, '%s\n', 'Timestamp (ms), Acquired frames, Saved frames');  % header
    end
  
    ses_state.frames_timestamps_numb = zeros(1, cam_numb);
    ses_state.cam_ind_to_refresh = int8(1);
    ses_state.t_refresh_GUI = timer('ExecutionMode', 'fixedRate', 'StartDelay', 0.5, 'Period', round(1/(ses_state.GUI_refresh_rate), 3), 'TimerFcn', @refresh_GUI);
    start(ses_state.t_refresh_GUI);

    function start_cam_acq(~, ~)
        for i=1:cam_numb
            flushdata(vidinp_obj_cam{i});
            start(vidinp_obj_cam{i});
        end
    end

    function start_strobe_out(src, ~)
        set(conf_obj_cam1{src.UserData}, 'LineSource', 'ExposureActive');
    end

    function stop_strobe_out(src, ~)
        set(conf_obj_cam1{src.UserData}, 'LineSource', 'ExternalTriggerActive');
    end


    function refresh_GUI(~, ~)
        if ses_state.cam_ind_to_refresh>cam_numb
            ses_state.cam_ind_to_refresh = 1;
        end
        
        i = ses_state.cam_ind_to_refresh;
        try
            set(handles.frames_acq{i}, 'String', num2str( vidinp_obj_cam{i}.FramesAcquired ));
            set(handles.frames_saved{i}, 'String', num2str( vidinp_obj_cam{i}.DiskLoggerFrameCount));
            set(handles.frames_aval{i}, 'String', num2str( vidinp_obj_cam{i}.FramesAvailable));
        catch
            disp('smth odd')
        end
                        
            try
                save_metadata_to_cvs(i);
            catch
                disp('Saving_metadata failed')
            end
            
            drawnow limitrate;
            ses_state.cam_ind_to_refresh = ses_state.cam_ind_to_refresh + 1;
    end

    function save_metadata_to_cvs(cam_ind)
        try
            [~, timestamps] = getdata(vidinp_obj_cam{cam_ind}, vidinp_obj_cam{cam_ind}.FramesAvailable );
        catch
            timestamps = [];
        end
        
        if ~isempty(timestamps) %check if frames are available in memory
            
%             FramesAcquired = vidinp_obj_cam{cam_ind}.FramesAcquired;      
            % FramesAcquired is a property of videoinput object; I dump timespamps from memory using FramesAvailable 
            % the increment in FramesAcquired should be close (+-1) to FramesAvailable, but they are not necessary equal. 
            % Hence for metadata purposes, I use length of acquired timestemps as a readout of instanteous FramesAcq_from_mem 
            
            FramesAcq_from_mem = ses_state.frames_timestamps_numb(cam_ind) + length(timestamps);
            FramesSaved = vidinp_obj_cam{cam_ind}.DiskLoggerFrameCount;
            
            fprintf(fid_met{cam_ind}, '%0.3f,%d,%d\n', [timestamps'*1000 ; (FramesAcq_from_mem - length(timestamps)+1: FramesAcq_from_mem) ;  repmat(FramesSaved, 1, length(timestamps)) ]);
            ses_state.frames_timestamps_numb(cam_ind) = FramesAcq_from_mem;

        else 
            if ses_state.cam_finished_acq(cam_ind) == 1 % finished camera acquisition
                if vidinp_obj_cam{cam_ind}.DiskLoggerFrameCount<vidinp_obj_cam{cam_ind}.FramesAcquired      % continue to log saved frames to disk (not really necessary, just for peace of mind)               
                    fprintf(fid_met{cam_ind}, '%0.3f,%d,%d\n', [0 ; vidinp_obj_cam{cam_ind}.FramesAcquired ;  vidinp_obj_cam{cam_ind}.DiskLoggerFrameCount ]);
                end
            end
        end
    end

    function stop_cam_acq(~, ~)
        for i = 1:cam_numb
            set(conf_obj_cam1{i}, 'LineSource', 'ExternalTriggerActive');       %manually shutdown strobe before stopping acqusition; can occasionally result in 1-2 extra frames in the end;
                                                                                %putting strobe shutdown into callback stop function is much less reliable for whatever reason (~5-8 less frames then strobe pulses)  
            stop(vidinp_obj_cam{i});
            ses_state.cam_finished_acq(i) = 1;
            set(conf_obj_cam1{i}, 'LineSelector', 'Line3'); % somehow fixes the bug of Line property becoming read-only on next run
            ses_state.frames_to_save(i) = (vidinp_obj_cam{i}.FramesAcquired - vidinp_obj_cam{i}.DiskLoggerFrameCount);
            pause(1);   % without it, when stopping cameras acquisition sequentially, 2nd or 3rd stop can sometimes lag and results in extra frames after frame pulses already stopped
        end
        wait_for = 120;  % s
        tic;
        paused_dur = 0;
        while (sum(ses_state.frames_to_save>0))&&(wait_for>paused_dur)
            pause(0.001);
            paused_dur = toc;
            if (ceil(paused_dur)-paused_dur)<0.001
                disp(['Saving... '  num2str(round(paused_dur)) 's'])
            end
        end
        
        for cam_ii = 1:cam_numb
            ses_state.frames_to_save(cam_ii) = (vidinp_obj_cam{cam_ii}.DiskLoggerFrameCount<vidinp_obj_cam{cam_ii}.FramesAcquired);

            if  ses_state.frames_to_save(cam_ii) == 0
                set(handles.frames_acq{cam_ii}, 'String', num2str( vidinp_obj_cam{cam_ii}.FramesAcquired ));
                set(handles.frames_saved{cam_ii}, 'String', num2str( vidinp_obj_cam{cam_ii}.DiskLoggerFrameCount));
                set(handles.frames_aval{cam_ii}, 'String', num2str( vidinp_obj_cam{cam_ii}.FramesAvailable));
                fprintf(fid_met{cam_ii}, '%0.3f,%d,%d\n', [0; vidinp_obj_cam{cam_ii}.FramesAcquired ;  vidinp_obj_cam{cam_ii}.DiskLoggerFrameCount ]);

                ses_state.clean_finish(cam_ii) = 1;
            else
                set(handles.frames_acq{cam_ii}, 'String', num2str( vidinp_obj_cam{cam_ii}.FramesAcquired ));
                set(handles.frames_saved{cam_ii}, 'String', num2str( vidinp_obj_cam{cam_ii}.DiskLoggerFrameCount));
                set(handles.frames_aval{cam_ii}, 'String', num2str( vidinp_obj_cam{cam_ii}.FramesAvailable));
                ses_state.clean_finish(cam_ii) = 0;

                disp([cam_settings.cam_name{cam_ii} 'camera: ' num2str(vidinp_obj_cam{cam_ii}.FramesAcquired - vidinp_obj_cam{cam_ii}.DiskLoggerFrameCount) ' frames were NOT SAVED'  ]);
            end
        end
        
        if sum(ses_state.clean_finish)==cam_numb
            disp('All frames are saved!');
        end
        
    end

    function end_session(~, ~)
        
        if isfield(ses_state, 't_refresh_GUI')
            stop(ses_state.t_refresh_GUI);
            delete(ses_state.t_refresh_GUI);
        end
        
        for i = 1:cam_numb
            conf_obj_cam1{i}.LineSelector = 'Line3'; % somehow fixes the bug of Line property becoming read-only on next run
            closepreview(vidinp_obj_cam{i});
            close(writer_obj_cam{i});
            delete(writer_obj_cam{i});
            delete(vidinp_obj_cam{i});
            fclose(fid_met{i});
        end

        close(handles.f);
        clearvars vidinp_obj_cam1 conf_obj_cam1 writer_obj_cam1
        
%         if sum(ses_state.cam_finished_acq)>0      % useful for initial testing
% %             data_integrity_check;
%         end
    end

    function draw_cam_axis_and_labels(start_x, start_y, cam_prev_W, cam_numb, space_btw)
        
        cam_prev_W_cams = repmat(cam_prev_W, 1, cam_numb);
        cam_prev_H_cams = round(cam_prev_W_cams*4/5);

        if cam_settings.crop_eye_camera == 1
            cam_prev_W_cams(2) = 0.75*cam_prev_W_cams(2);
        end

        for i = 1:cam_numb
            
            if i == 1
                uicontrol('Parent', handles.f,'Units','pixels','Style','text','Enable','inactive','Position', [start_x-70 start_y-60 100 50], 'String', 'Frames:','FontSize', 12);
            end
            
            cam_pos_y = start_y;
            cam_pos_x = start_x + (i-1)*(cam_prev_W_cams(1)+space_btw);
            handles.cam_prev_ax{i} = axes('Parent', handles.f, 'Units','pixels','Position', [cam_pos_x cam_pos_y cam_prev_W_cams(i) cam_prev_H_cams(i) ],'LineWidth',0.001,'XTick',[],'YTick',[]);

            cam_prev_ax_x_middle = cam_pos_x + cam_prev_W_cams(i)/2;
            step_x = round(cam_prev_W_cams(1)-20)/3;
            
            uicontrol('Parent', handles.f,'Units','pixels','Style','text','Enable','inactive','Position', [cam_prev_ax_x_middle-50-step_x cam_pos_y-60 100 50], 'String', 'Acquired','FontSize', 12);
            uicontrol('Parent', handles.f,'Units','pixels','Style','text','Enable','inactive','Position', [cam_prev_ax_x_middle-50 cam_pos_y-60 100 50], 'String', 'Saved','FontSize', 12);
            uicontrol('Parent', handles.f,'Units','pixels','Style','text','Enable','inactive','Position', [cam_prev_ax_x_middle-50+step_x cam_pos_y-60 100 50], 'String', 'Available','FontSize', 12);

            handles.frames_acq{i} = uicontrol('Parent',handles.f,'Units','pixels','Style','edit', 'Position', [cam_prev_ax_x_middle-30-step_x cam_pos_y-70 60 30],'FontSize', 12, 'String', '0');
            handles.frames_saved{i} = uicontrol('Parent',handles.f,'Units','pixels','Style','edit', 'Position', [cam_prev_ax_x_middle-30 cam_pos_y-70 60 30],'FontSize', 12, 'String', '0');
            handles.frames_aval{i} = uicontrol('Parent',handles.f,'Units','pixels','Style','edit', 'Position', [cam_prev_ax_x_middle-30+step_x cam_pos_y-70 60 30],'FontSize', 12, 'String', '0');
        end
    end

    function data_integrity_check
        
        disp('Expected number of frame pulses:');
        for i = 1: cam_numb
            vid_tmp = VideoReader( fullfile(ses_state.video_save_path, [ses_state.session_name '_' cam_settings.cam_name{i} '_cam.mp4']));
            framerate = vid_tmp.FrameRate;
            IFI = 1000/framerate;
            frames_acq_numb = vid_tmp.NumFrames;
            timestamps = readmatrix( fullfile(ses_state.video_save_path, [ses_state.session_name '_' cam_settings.cam_name{i} '_cam_metadata.csv']) );
            timestamps = timestamps(1:100, 1);
            timestamps_IFI = diff(timestamps);
            fake_early_frames = find(timestamps_IFI > 0.9*IFI, 1, 'first') - 1;
            
            disp([ cam_settings.cam_name{i} ' camera: ' num2str(frames_acq_numb - fake_early_frames  )])
            
        end
    end

end


