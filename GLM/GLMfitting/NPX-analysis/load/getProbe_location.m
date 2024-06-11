function probe_coord = getProbe_location(path)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd(path);

probe_coord_tmp = jsondecode(fileread('channel_locations.json')); 
channel_names = fieldnames(probe_coord_tmp);

for i = 1:length(channel_names)-1
    probe_coord(i) = probe_coord_tmp.(channel_names{i});
    probe_coord(i).x = probe_coord(i).x/1000;
    probe_coord(i).y = probe_coord(i).y/1000;
    probe_coord(i).z = probe_coord(i).z/1000;
end


end

