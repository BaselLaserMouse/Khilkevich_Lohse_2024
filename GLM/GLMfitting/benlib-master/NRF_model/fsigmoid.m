function [p] = fsigmoid(x)
% Sigmoid function: s(x) = 1 / (1+exp(-x))
p = 1./(1+exp(-x));
end

