function [vol, a_loc] = get_annotation_volume(annotation, A, varargin)

default_options = struct(...
    'size', [15 15 7] ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);

if size(A,4) > 1
    A = get_slice(annotation.time);
end

coords = annotation.position;
coords_int = round(coords);
coords_frac = coords - coords_int;

offset = floor(options.size/2);

vol = get_image_section(coords_int-offset, options.size-1, A);
a_loc = annotation.clone_child();
a_loc.position = offset + coords_frac + 1;