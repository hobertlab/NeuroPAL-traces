function s = calculate_signal(center, volume, varargin)

default_options = struct(...
    'feature_size', [5, 5, 3], ...
    'points_to_keep', 25 ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);

vol = get_centered_section(volume, center, options.feature_size);
values = sort(vol(:), 'descend');
s = mean(values(1:options.points_to_keep));

end

