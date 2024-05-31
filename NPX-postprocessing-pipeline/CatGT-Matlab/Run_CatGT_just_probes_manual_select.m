function Run_CatGT_just_probes_user

    cd('D:\SGL_DATA');  %default NPX data directory
    [binName, path] = uigetfile('*.bin', 'Select NI Binary File');
    ind = strfind(binName, '_g0');
    ses_name = binName(1:ind-1);

    dir_cont = dir(path);
    dir_cont(1:2) = [];
    
    probe_count = 0;
    for i=1:length(dir_cont)
        if ~isempty( strfind(dir_cont(i).name, 'imec'))
            probe_count = probe_count + 1;
        end
    end
    
    if probe_count<1
        disp('No imec folders are found?!')
    else
        
        code_path = 'C:\Users\NPX1\Documents\code\DMDM_NPX_postprocessing_tools\CatGT-Matlab';
        cd(code_path);
        bat_id = fopen('CatGT_templ_probes_only.bat');
        bat_templ = textscan(bat_id, '%s', 'Delimiter', '^');
        line2 = bat_templ{1}{2};

        ind_start = strfind(line2, '-run=')+4;
        ind_end = strfind(line2, '-g=')-1;
        line2_new = [line2(1:ind_start) ses_name line2(ind_end:end)];

        bat_new = bat_templ{1};
        bat_new{2} = line2_new;

        if probe_count>=2
           for pr = 2:probe_count
               bat_new{4} = [bat_new{4} ',' num2str(pr-1)];
               bat_new{6} = [bat_new{6} ' ' '-SY=' num2str(pr-1) ',384,6,500'];
           end
        end

        for i = 1:length(bat_new)-1
            bat_new{i+1} = [bat_new{i+1} ' ^'];    
        end

        bat_new_id = fopen('Run_CatGT.bat','w'); 
        fprintf(bat_new_id, '%s\n', bat_new{:});
        fclose(bat_new_id);

        system('Run_CatGT.bat');
    end


end

