function frMatrCntr = centerFrMatr(frMatr, varargin)
%UNTITLED5 Summary of this function goes here

if isempty(varargin)
    frMatrCntr = frMatr - mean(frMatr, 1) - mean(frMatr, 2);    
    frMatrCntr = frMatrCntr - mean(mean(frMatrCntr));  
else
    dim = varargin{1};
    if isempty(dim)
        frMatrCntr = frMatr - mean(frMatr, 1) - mean(frMatr, 2);    
        frMatrCntr = frMatrCntr - mean(mean(frMatrCntr));  
    else
        if dim==0
            frMatrCntr = frMatr;
        else
            frMatrCntr = frMatr - mean(frMatr, dim);    
        end
    end
end
    
end

