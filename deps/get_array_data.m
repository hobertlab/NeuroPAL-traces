function y = get_array_data(x)
% y = GET_ARRAY_DATA(x)
%
%   Returns the numeric data in array x (idempotent).
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)


S = size(x);

if length(S) < 2
   y = zeros([S 1], element_class(x));
else
   y = zeros(S, element_class(x));
end

idx = cell(1,ndims(x));
[idx{:}] = deal(':');

for i = 1:S(end)
    
    idx{end} = i;
    y(idx{:}) = get_slice(x, i);
    
end