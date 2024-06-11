function [p] = fprimesigmoid(x)
%First derivative of sigmoid function expressed as the sigmoid function
%itself
p=fsigmoid(x).*(1.-fsigmoid(x));
end

