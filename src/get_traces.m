function row = get_traces(row)


% Registration frame sizes.

frame_size_score = [21 21 7];
frame_size_coarse_reg = [21 21 7];


% Load volumes
S = load(fullfile(row.data_path, 'data.mat'));
data = S.data;

% Load annotations
S = load(fullfile(row.data_path, 'annotations.mat'));
A = S.A;
A = A.consolidate_best();

get_vol = @(x) get_slice(data, x);

size_T = size(data, 4);
t_src = 2;
Vs = get_vol(t_src);
A_src = A.get_t(t_src);
neurons = A_src.worldlines();

for t_tgt = 3:size_T

    fprintf('animal %s: %d\n', row.animal, t_tgt);
    Vt = get_vol(t_tgt);
    
    A_prv = A.get_t(t_tgt-1);

    A_tgt = Annotations();

    for n = neurons'

        as = A_src.get_worldline(n).get(1);
        a_guess = A_prv.get_worldline(n).get(1);

        at_coarse = register_annotation_image_based(...
            as, Vs, Vt, frame_size_coarse_reg, ...
            'guess_annotation', a_guess);
        at_coarse.confidence = get_registration_score(...
            as, Vs, at_coarse, Vt, frame_size_score) ...
            * as.confidence;

        at_best = at_coarse;


        at_best.time = t_tgt;
        A_tgt = A_tgt.push(at_best);
        
    end

    A = A.cat(A_tgt);
end

save(fullfile(row.data_path, 'annotations.mat'), 'A');

annotations_gcamp_extended = calculate_signal_from_annotations(A, data);

AG = annotations_gcamp_extended;
AG_no_id = AG(AG.time>1, :);
AG_no_id.time = AG_no_id.time - 1;

annotations_gcamp = AG_no_id;

annotations_file = fullfile(row.data_path, 'annotations_gcamp.mat');
save(annotations_file, 'annotations_gcamp');

trace_array = nan(length(neurons), size_T - 1);

for n = neurons'
    neuron_tbl = sortrows(AG_no_id(AG_no_id.worldline_id==n, :), 'time');
    t_list = neuron_tbl.time - 1;
    gc = neuron_tbl.GCaMP;
    for t_idx = 1:length(t_list)
        try
            trace_array(n,t_list(t_idx)) =  gc(t_idx);
        catch
        end
    end
end

metadata_file = fullfile(row.data_path, 'metadata.mat');
S = load(metadata_file);
input_neurons = S.input_neurons;
stimulus_seconds = S.stimulus_seconds;
times = S.times;

traces_file = fullfile(row.data_path, 'traces.mat');
save(traces_file, 'trace_array', 'input_neurons', 'stimulus_seconds', ...
    'times');