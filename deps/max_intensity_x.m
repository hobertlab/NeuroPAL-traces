function output = max_intensity_x(vol)
% y = MAX_INTENSITY_X(vol)
%
%   Create a maximum intensity projection in the x-direction (yz-plane). The
%   resulting size is [S(1), S(3)], where S = size(vol).
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

output = squeeze(max(vol,[],2));
