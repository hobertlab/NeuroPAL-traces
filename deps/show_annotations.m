function show_annotations(annotations, A, varargin)

default_options = struct(...
    'pixel_scale', [1, 1, 4] ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);

coords = annotations.positions();

size_X = size(A, 2);
size_Y = size(A, 1);

ps = options.pixel_scale;

view = ThreeViewArray.combine_MIPs(A, ps);
imshow(autoscale(view));
hold on;

coords(:,1) = coords(:,1) * ps(1) - (ps(1) - 1)/2;
coords(:,2) = coords(:,2) * ps(2) - (ps(2) - 1)/2;
coords(:,3) = coords(:,3) * ps(3) - (ps(3) - 1)/2;

plot(coords(:,2), coords(:,1), '.r', 'LineWidth', 2);
plot(size_X + 2 + coords(:,3), coords(:,1), '.r', 'LineWidth', 2);
plot(coords(:,2), size_Y + 2 + coords(:,3), '.r', 'LineWidth', 2);
