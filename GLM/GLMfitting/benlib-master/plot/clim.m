function a = clim(arg1, arg2)
% like xlim but for colour

if nargin == 0
    a = get(gca,'clim');
else
    if isscalar(arg1) && ishghandle(arg1,'axes')
        ax = arg1;
        if nargin==2
            val = arg2;
        else
            a = get(ax,'clim');
            return
        end
    else
        if nargin==2
            error('MATLAB:clim:InvalidNumberArguments', 'Wrong number of arguments')
        else
            ax = gca;
            val = arg1;
        end
    end

    if ischar(val)
        if(strcmp(val,'mode'))
            a = get(ax,'climmode');
        else
            set(ax,'climmode',val);
        end
    else
        set(ax,'clim',val);
    end
end
