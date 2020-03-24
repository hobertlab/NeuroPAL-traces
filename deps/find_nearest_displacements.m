function [y, vals] = find_nearest_displacements(A_src, A_tgt, ...
    worldline, N)

    a = A_src.get_worldline(worldline).get_best();
    
    src_worldlines = A_src.worldlines();
    tgt_worldlines = A_tgt.worldlines();
    common = intersect(src_worldlines, tgt_worldlines);
    
    A_src_filtered = A_src.filter(@(x) ismember(x.worldline_id, common));
    A_tgt_filtered = A_tgt.filter(@(x) ismember(x.worldline_id, common));
    
    if ~ismember(a.id, A_src_filtered.Table.id)
        A_src_filtered = A_src_filtered.push(a);
    end

    [nearest, vals] = A_src_filtered.find_nearest(a.id, N);

    y = zeros(3,0);
    for w = nearest.worldlines()'
        s = nearest.get_worldline(w).get_best();
        t = A_tgt_filtered.get_worldline(w).get_best();
        y(:,end+1) = column(t.position - s.position);
    end

end

