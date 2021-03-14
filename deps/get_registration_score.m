function score = get_registration_score(source_annotation, source_volume, ...
    target_annotation, target_volume, frame_size, varargin)

default_options = struct(...
    'direction_weights', [0.25 0.25 0.5] ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);
get_MIPs = @(vol, center) ...
    get_expanded_MIPs(vol, center, frame_size, [0 0 0]);

[sx, sy, sz] = get_MIPs(source_volume, source_annotation.position());
[tx, ty, tz] = get_MIPs(target_volume, target_annotation.position());

score_x = get_image_overlap(sx, tx);
score_y = get_image_overlap(sy, ty);
score_z = get_image_overlap(sz, tz);

score = options.direction_weights*[score_y; score_x; score_z];