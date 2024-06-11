function varargout = itemise(x)
% parcel out elements of a matrix or cell, so that:
% [a b c d] = itemise([a b c d])

for ii = 1:length(x)
    if iscell(x)
        varargout{ii} = x{ii};
    else
        varargout{ii} = x(ii);
    end
end
