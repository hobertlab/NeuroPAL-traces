function A = remove_duplicate_ids(A, B)

rng shuffle;

A_ids = A.Table.id;
B_ids = B.Table.id;

AB_ids = intersect(A_ids, B_ids);

tbl = A.Table;

for i = 1:length(AB_ids)
    
    old = AB_ids{i};
    new = get_id(9);
    
    for j = 1:length(A)
        if strcmp(tbl.id{j}, old)
            tbl.id{j} = new;
            tbl.Properties.RowNames{j} = new;
        end
        if strcmp(tbl.parent_id{j}, old)
            tbl.parent_id{j} = new;
        end
    end
    
end

A.Table = tbl;
