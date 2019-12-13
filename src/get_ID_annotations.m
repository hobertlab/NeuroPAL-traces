function row = get_ID_annotations(row)


% Load volumes
S = load(fullfile(row.data_path, 'data.mat'));
data = S.data;

% Load annotations
S = load(fullfile(row.data_path, 'annotations.mat'));
A = S.A;

get_vol = @(x) get_slice(data, x);

neurons = A.worldlines();
size_N = length(neurons);

% Registration frame sizes.
frame_size_centroid = [7 7 5];
frame_size_score = [21 21 7];
frame_size_coarse_reg = [21 21 7];
imreg_padding_id = [11 11 3];

% annealing parameters
alignment_radius = 30;
alignment_confidence_threshold = 0.7;
alignment_N = 4;
alpha = 1; % fraction of distance to travel towards concensus target.

Vs = get_vol(1);
for i = 1:size_N

    a = A.get_t(1).get_worldline(neurons(i)).get_best();


    a_adj = register_annotation_centroid(a, Vs, frame_size_centroid);
    a_adj.confidence = a_adj.confidence + eps;

    if isnan(a_adj.confidence)
        a_adj.confidence = 0;
    end

    if all(~isnan(a_adj.position))
        A = A.push(a_adj);
    end
end


% Add fiducial neurons
if size_N < 20
    A_anon = find_neurons(Vs, 20-size_N);
    A = A.cat(A_anon);
    neurons = A.worldlines();
    size_N = length(neurons);
end

% Stitch first frame

t_src = 1;
t_tgt = 2;

Vs = get_vol(t_src);
Vt = get_vol(t_tgt);

A_src = A.get_t(t_src).consolidate_best();

A_tgt = Annotations();
for n = neurons'

    as = A_src.get_worldline(n).get(1);

    at_triv = as.clone_child();
    at_triv.confidence = get_registration_score(...
        as, Vs, as, Vt, frame_size_score);

    at_coarse = register_annotation_image_based(...
        as, Vs, Vt, frame_size_coarse_reg, ...
        'imreg_padding', imreg_padding_id);
    at_coarse.confidence = get_registration_score(...
        as, Vs, at_coarse, Vt, frame_size_score);

    at_fine = register_annotation_centroid(...
        at_coarse, Vt, frame_size_centroid);
    if any(isnan(at_fine.position))
        at_fine = at_coarse;
    end
    at_fine.confidence = get_registration_score(...
        as, Vs, at_fine, Vt, frame_size_score);

    at_fine.time = t_tgt;
    A_tgt = A_tgt.push(at_fine);


end

% Use the good matches to find a better first guess.
A_tgt_good = A_tgt.filter(...
    @(x) x.confidence > alignment_confidence_threshold);
N_good = size(A_tgt_good, 1);
all_displacements = find_annotation_displacements(A_src, A_tgt_good);
guess_offset = median(all_displacements, 1);
fraction_good = 0;
tries = 0;

while fraction_good < 0.5 && tries < 3

    A_tgt = Annotations();
    for n = neurons'

        as = A_src.get_worldline(n).get(1);

        at_triv = as.clone_child();
        at_triv.position = clip_coordinates(...
            at_triv.position + guess_offset, ...
            size(Vs));
        at_triv.confidence = get_registration_score(...
            as, Vs, as, Vt, frame_size_score);

        at_coarse = register_annotation_image_based(...
            as, Vs, Vt, frame_size_coarse_reg, ...
            'imreg_padding', imreg_padding_id, ...
            'guess_annotation', at_triv);
        at_coarse.confidence = get_registration_score(...
            as, Vs, at_coarse, Vt, frame_size_score);

        at_fine = register_annotation_centroid(...
            at_coarse, Vt, frame_size_centroid);
        if any(isnan(at_fine.position))
            at_fine = at_coarse;
        end
        at_fine.confidence = get_registration_score(...
            as, Vs, at_fine, Vt, frame_size_score);

        at_fine.time = t_tgt;
        A_tgt = A_tgt.push(at_fine);

    end
    % Use the good matches to find a better first guess.
    A_tgt_good = A_tgt.filter(...
        @(x) x.confidence > alignment_confidence_threshold);
    N_good = size(A_tgt_good, 1);
    all_displacements = find_annotation_displacements(A_src, A_tgt_good);
    guess_offset = median(all_displacements, 1);
    fraction_good = N_good/size_N;
    tries = tries + 1;
end

A_tgt_anneal = Annotations();
for n = neurons'

    a_tgt = A_tgt.get_worldline(n).get_best();
    a_src = A_src.get_worldline(n).get_best();

    if isempty(a_tgt)
        a_tgt = a_src.clone_child();
        a_tgt.time = t_tgt;
    end

    [nearest, dists] = find_nearest_displacements(A_src, A_tgt_good, n, ...
        alignment_N);

    within_radius = find(dists < alignment_radius);
    N = length(within_radius);
    near_enough = nearest(:,within_radius);

    a_anneal = a_tgt.clone_child();
    if N > 0
        src_offset = median(near_enough, 2)';
        concensus_tgt = a_src.position + src_offset;
        concensus_offset = concensus_tgt - a_tgt.position;
        offset = concensus_offset * alpha;
        a_anneal.position = a_anneal.position + offset;
    end
    a_anneal.confidence = get_registration_score(...
        a_src, Vs, a_anneal, Vt, frame_size_score);

    A_tgt_anneal = A_tgt_anneal.push(a_anneal);

end
A_tgt = A_tgt.cat(A_tgt_anneal);

A_tgt = A_tgt.consolidate_best();
A = A.cat(A_tgt);

% Save annotations
save(fullfile(row.data_path, 'annotations.mat'), 'A');
