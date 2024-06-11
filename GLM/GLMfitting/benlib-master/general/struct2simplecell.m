function cell = struct2simplecell(struct)

cell = {};

for ii = 1:length(struct)
 	cell{ii} = struct(ii);
end