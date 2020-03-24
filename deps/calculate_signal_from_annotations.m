function tbl = calculate_signal_from_annotations(A, data, varargin)

default_options = struct(...
    'feature_size', [5, 5, 3], ...
    'points_to_keep', 25 ...
);

input_options = varargin2struct(varargin{:}); 
options = merge_struct(default_options, input_options);

s = zeros(length(A), 1);

tbl = A.Table;

all_times = A.times_set();

for t = all_times'
    tbl_rows = find(tbl.time == t);
    vol = get_slice(data, t);
    for i = tbl_rows'
        a = tbl(i,:);
        s(i) = calculate_signal(a.position, vol, options);
    end
end

tbl.GCaMP = s;