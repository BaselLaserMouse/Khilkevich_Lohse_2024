
ses_state.video_save_path = 'D:\NPX_video';
ses_state.code_path = 'C:\Users\NPX1\Documents\code';
ses_state.session_name = 'SessionName';

cd(ses_state.video_save_path);
mkdir(ses_state.session_name);

ses_state.video_save_path = fullfile(ses_state.video_save_path, ses_state.session_name);
ses_state.GUI_refresh_rate = 30;
cd(ses_state.code_path);

cam_settings.cameras_number = 2;
ses_state.cam_finished_acq = zeros(1, cam_settings.cameras_number);
ses_state.frames_to_save = zeros(1, cam_settings.cameras_number);
cam_settings.framerate{1} = 100;
cam_settings.framerate{2} = 50;
cam_settings.cam_name{1} = 'Front';
cam_settings.cam_name{2} = 'Eye';
cam_settings.crop_eye_camera = 1;

for i=1:cam_settings.cameras_number
    ses_state.metadata_path_and_name{i} = fullfile(ses_state.video_save_path, [ses_state.session_name '_' cam_settings.cam_name{i} '_cam_metadata.csv']);
end
warning('off','MATLAB:audiovideo:VideoWriter:noFramesWritten');

run_cam_acq(ses_state, cam_settings);



