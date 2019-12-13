function c = element_class(A)
% c = ELEMENT_CLASS(A)
%
%   Returns the class of elements in array A. This primarily provides an
%   alternative method to overload when defining custom arrays.
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

c = class(A);