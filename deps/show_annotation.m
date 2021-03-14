function show_annotation(annotation, A, varargin)

default_options = struct(...
    'size', [15 15 7], ...
    'pixel_scale', [1, 1, 2] ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);

[vol, a_loc] = get_annotation_volume(annotation, A, options);

As = Annotations();
As = As.push(a_loc);

show_annotations(As, vol, options);