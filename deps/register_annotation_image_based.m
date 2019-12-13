function annotation = register_annotation_image_based(...
    source_annotation, source_volume, ...
    target_volume, ...
    frame_size, ...
    new_t, ...
    varargin)

default_options = struct(...
    'guess_annotation', [], ...
    'drift', [3, 3, 1], ...
    'imreg_padding', [3, 3, 1], ...
    'steps', 1, ...
    'fine_tune', false, ...
    'lookup_threshold', 0.1 ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);

if isempty(options.guess_annotation)
    guess_annotation = source_annotation;
else
    guess_annotation = options.guess_annotation;
end

guess = [guess_annotation.y guess_annotation.x guess_annotation.z];

frame_radius = floor(frame_size/2);
frame_size = 2*frame_radius + 1;

get_local_vol = @(vol, center) ...
    get_image_section(center-frame_radius, ...
        frame_size, ...
        vol);

get_MIPs = @(vol, center) ...
    get_expanded_MIPs(vol, center, frame_size, [0 0 0]);

get_large_MIPs = @(vol, center) ...
    get_expanded_MIPs(vol, center, frame_size, ...
        options.imreg_padding);


src_coord = source_annotation{1, {'y', 'x', 'z'}};

[px, py, pz] = get_MIPs(source_volume, src_coord);
[cxs, cys, czs] = get_MIPs(target_volume, guess);
[cx, cy, cz] = get_large_MIPs(target_volume, guess);

offset_from_x = register_image(px, cx, 'iterations', 1, ...
    'threshold', 0.8, 'pyramids', 1, 'config_type', 'multimodal', options);
offset_from_y = register_image(py, cy, 'iterations', 1, ...
    'threshold', 0.8, 'pyramids', 1, 'config_type', 'multimodal', options);
offset_from_z = register_image(pz, cz, 'iterations', 1, ...
    'threshold', 0.8, 'pyramids', 1, 'config_type', 'multimodal', options);

new_x = guess(2) + offset_from_z(2);
new_y = guess(1) + offset_from_z(1);
new_z = guess(3) + mean([offset_from_x(2), offset_from_y(1)]);

new_center = [new_y, new_x, new_z];

[~, ~, nz] = get_MIPs(target_volume, new_center);
score = get_image_overlap(pz, nz);

new_row = source_annotation;

id_tokens = strsplit(new_row.id{1}, '_');
id_tokens{end} = num2str(new_t);
new_id = strjoin(id_tokens, '_');

new_row.id = {new_id};
new_row.Properties.RowNames{1} = new_id;
new_row.x = new_x;
new_row.y = new_y;
new_row.z = new_z;
new_row.t = new_t;
new_row.confidence = score * 0.95;
new_row.trace = {[]};

annotation = new_row;