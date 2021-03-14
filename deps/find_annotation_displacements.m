function y = find_annotation_displacements(A_src, A_tgt)

w_s = A_src.worldlines();
w_t = A_tgt.worldlines();

all_w = intersect(w_s, w_t);

i = 1;
for w = all_w'
    pos_s = A_src.get_worldline(w).get_best().position;
    pos_t = A_tgt.get_worldline(w).get_best().position;
    y(i,:) = pos_t - pos_s;
    i = i + 1;
end