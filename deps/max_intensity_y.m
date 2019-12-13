function output = max_intensity_y(vol)
% y = MAX_INTENSITY_Y(vol)
%
%   Create a maximum intensity projection in the y-direction (zx-plane). The
%   resulting size is [S(3), S(2)], where S = size(vol).
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

N = ndims(vol);
output = permute(squeeze(max(vol,[],1)), [2 1 3:N]);
