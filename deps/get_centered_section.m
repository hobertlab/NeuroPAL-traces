function section = get_centered_section(image, center_coords, feature_size)
% section = GET_CENTERED_SECTION(A, center_coords, feature_size)
%
%   Return a section of A centered around center_coords with a specified
%   size. Center_coords can be specified in a subpixel way (though the
%   returned image won't involve any subpixel interpolation).
%
%   GET_CENTERED_SECTION(3.0, 2, A) -> A(2:3)
%   GET_CENTERED_SECTION(3.0, 3, A) -> A(2:4)
%   GET_CENTERED_SECTION(3.1, 2, A) -> A(3:4)
%   GET_CENTERED_SECTION(3.1, 3, A) -> A(2:4)
%   GET_CENTERED_SECTION(3.4, 2, A) -> A(3:4)
%   GET_CENTERED_SECTION(3.4, 3, A) -> A(2:4)
%   GET_CENTERED_SECTION(3.6, 2, A) -> A(3:4)
%   GET_CENTERED_SECTION(3.6, 3, A) -> A(3:5)
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)


start_indices = ceil(center_coords - feature_size/2);

section = get_section(image, start_indices, feature_size);
