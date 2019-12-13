function section = get_section(image, start_indices, feature_size)
% function section = GET_SECTION(image, start_indices, feature_size)
%
%   Extracts a section of an image with coordinates starting at
%   'start_indices' and a size of 'size'.  Boundaries are padded with the 
%   average value on the face to allow extraction of regions that jut out
%   of the original image.
%
%   If feature_size has fewer dimensions than the image, no sectioning is
%   done on trailing dimensions.
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

S = size(image);
N = ndims1(image); 

start_indices = round(start_indices);
feature_size = round(feature_size);

M = length(start_indices);
assert(M==length(feature_size), ...
    'Start index and feature size must be the same dimension.');        
start_indices(M+1:N) = 1;
feature_size(M+1:N) = S(M+1:N);

% Determine the average value of border pixels.
border_pixels = [];
for i=1:N
    for j=1:N
        if j==i
            idx{j} = [1 S(j)];
        else
            idx{j} = [1:S(j)];
        end
    end
    border_pixels = [border_pixels ...
                     reshape(image(idx{:}),1,numel(image(idx{:})))];
end
background_intensity = mean(border_pixels);
clear border_pixels;

section = ones(feature_size, element_class(image)) * background_intensity;

section_idx = cell(1,N);
image_idx = cell(1,N);
end_indices = start_indices + feature_size - 1;
for i = 1:N
    if start_indices(i) < 1
        image_start = 1;
        section_start = 2-start_indices(i);
    else
        image_start = start_indices(i);
        section_start = 1;
    end
    
    if  end_indices(i) <= S(i)
        image_end = end_indices(i);
        section_end = feature_size(i);
    else
        image_end = S(i);
        section_end = feature_size(i) - (end_indices(i) - S(i));
    end

    section_idx{i} = section_start:section_end;
    image_idx{i} = image_start:image_end;

end

section(section_idx{:}) = image(image_idx{:});
