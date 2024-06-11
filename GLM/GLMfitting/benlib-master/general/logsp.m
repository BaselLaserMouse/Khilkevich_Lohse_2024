function l = logsp(min, max, varargin)
% function l = logsp(min, max, varargin)
% 
% logsp(min, max, ...) = logspace(log10(min), log10(max), ...)

l = logspace(log10(min), log10(max), varargin{:});
