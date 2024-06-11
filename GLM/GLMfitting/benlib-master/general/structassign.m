function structarray = structassign(structarray, ii, strct)
% function strct = structassign(strct, ii, strct)
%
% Assign a struct to the iith element of structarray
% even if the field names don't match.
%
% The output struct array will have the same fieldnames as strct; 
% any other fields will be dropped
% 
% Inputs:
%  structarray -- the parent structure
%  ii -- index
%  strct -- the new element to go into the array at index ii

oldfieldlist = fieldnames(structarray);
newfieldlist = fieldnames(strct);

fields_to_remove = setdiff(oldfieldlist, newfieldlist);
fields_to_add = newfieldlist;

for f = 1:length(fields_to_remove)
  structarray = rmfield(structarray, fields_to_remove{f});
end

for f = 1:length(fields_to_add)
  structarray(ii).(fields_to_add{f}) = strct.(fields_to_add{f});
end
