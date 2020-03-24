function y = autoscale(x, LUT_in)
% y = AUTOSCALE(x)
%
%   Returns an array y that is the same class as x that fills the output
%   range of class(x). ([0, 1] for floating point data).
%
% [y, LUT] = AUTOSCALE(x)
%
%   Additionally returns the lookup table.
%
% y = AUTOSCALE(x, LUT_in)
%
%   Uses the provided LUT to scale an image.
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

if nargin < 2
    LUT_in = [min_all(x), max_all(x)];
end

if isfloat(x)
    LUT = [0, 1];
elseif isinteger(x)
    LUT = [intmin(class(x)), intmax(class(x))];
end

y_float = interp1(double(LUT_in), double(LUT), double(x));
y = cast(y_float, 'like', x);