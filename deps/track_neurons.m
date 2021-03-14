function A = track_neurons(A, data)

% Registration frame sizes.

frame_size_score = [51 51 7];
frame_size_coarse_reg = [51 51 7];

get_vol = @(x) get_slice(data, x);

size_T = size(data, 4);
t_src = min(A.times_set());
Vs = get_vol(t_src);
A_src = A.get_t(t_src);
neurons = A_src.worldlines();
f
for t_tgt = (t_src+1):size_T

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
