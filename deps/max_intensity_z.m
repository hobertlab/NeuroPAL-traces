function output = max_intensity_z(vol)
% y = MAX_INTENSITY_Z(vol)
%
%   Create a maximum intensity projection in the z-direction (yx-plane). The
%   resulting size is [S(1), S(2)], where S = size(vol).
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

output = squeeze(max(vol,[],3));
