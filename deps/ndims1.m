function n = ndims1(x)
% n = NDIMS1(x)
%
%   Return the number of dimensions, but returns 1 if x is a row or column
%   vector.

n = ndims(x);

if n==2 && (size(x,1)==1 || size(x,2)==1)
    n = 1;
end