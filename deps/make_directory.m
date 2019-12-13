function make_directory(directory_name, varargin)
% MAKE_DIRECTORY(directory_name)
%
%   This will create the directory specified if it doesn't exist.
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

if ~exist(directory_name, 'dir')
    mkdir(directory_name);
end