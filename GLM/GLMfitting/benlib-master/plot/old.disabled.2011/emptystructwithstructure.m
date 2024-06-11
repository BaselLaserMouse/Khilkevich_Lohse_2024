function emptystruct = emptystructwithstructure(modelstruct)
% function emptystruct = structwithstructure(modelstruct)
% 
% BW 2008-05-18
% This is the ugliest function ever written.
% It will return a 0x0 structure with fieldnames identical to
% modelstruct
% Please don't look at the code to find out how it's done.

fn = fieldnames(modelstruct);

cmd = 'emptystruct = struct(';
for ii = 1:length(fn)-1
  cmd = [cmd '''' fn{ii} ''', {},'];
end
cmd = [cmd '''' fn{end} ''', {});'];
eval(cmd);
