function [MIPx, MIPy, MIPz] = get_expanded_MIPs(vol, center, siz, padding)
% [MIPx, MIPy, MIPz] = GET_EXPANDED_MIPs(vol, center, siz, padding)
%
%   Returns maximum intensity projections of a volume around the point
%   center. siz contains the volume of points to be included in every
%   MIP, while padding should contain the number of additional points to be
%   added to each side in the non-projected direction. Specifically, 
%
%       size(MIPz_vol, 3) = siz(3)
%       size(MIPz_vol, 1) = siz(1) + 2*padding(1)
%       size(MIPz_vol, 2) = siz(2) + 2*padding(2)

s_x = siz;
s_x(1) = s_x(1) + 2*padding(1);
s_x(3) = s_x(3) + 2*padding(3);

s_y = siz;
s_y(2) = s_y(2) + 2*padding(2);
s_y(3) = s_y(3) + 2*padding(3);

s_z = siz;
s_z(1) = s_z(1) + 2*padding(1);
s_z(2) = s_z(2) + 2*padding(2);

v_x = get_centered_section(vol, center, s_x);
v_y = get_centered_section(vol, center, s_y);
v_z = get_centered_section(vol, center, s_z);

MIPx = max_intensity_x(v_x);
MIPy = max_intensity_y(v_y);
MIPz = max_intensity_z(v_z);