
function structureTreeTable = loadStructureTree_short(fn)
% function structureTreeTable = loadStructureTree(fn)
% note: use an edited version that doesn't have commas in any fields... 

% fn = 'structure_tree_safe.csv';

if nargin<1
    p = mfilename('fullpath');
    fn = fullfile(fileparts(fileparts(p)), 'structure_tree_safe_2017.csv');
end

[~, fnBase] = fileparts(fn);
if ~isempty(strfind(fnBase, '2017'))
    mode = '2017'; 
else
    mode = 'old'; 
end

fid = fopen(fn, 'r');

if strcmp(mode, 'old')
    titles = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 1, 'delimiter', ',');
    titles = cellfun(@(x)x{1}, titles, 'uni', false);
    titles{1} = 'index'; % this is blank in the file
    
    data = textscan(fid, '%d%s%d%s%d%s%d%d%d%d%d%s%s%d%d%s%d%s%s%d%d', 'delimiter', ',');
    
elseif strcmp(mode, '2017')
    titles = textscan(fid, repmat('%s', 1, 4), 1, 'delimiter', ',');
    titles = cellfun(@(x)x{1}, titles, 'uni', false);
    
    data = textscan(fid, ['%d%d%s%s'], 'delimiter', ','); % 'id'    'atlas_id'    'name'    'acronym'
    
    titles = ['index' titles];
    data = [[0:numel(data{1})-1]' data];    
    

end


structureTreeTable = table(data{:}, 'VariableNames', titles);

fclose(fid);