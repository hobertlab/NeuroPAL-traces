function A = find_neurons(V, N)

debug_plot = false;

%% Find local maxima.
maxima = find_local_maxima(V, [7 7 3], 'minimum_separation', [10, 10, 5],...
    'max', N);
size_N = size(maxima, 1);
A = Annotations();

worldline_offset = 500;
for i = 1:size_N
    a = Annotation(maxima(i,:), 1, worldline_offset + i, 0.99, []);
    ac = register_annotation_centroid(a, V, [5 5 3]);
    if debug_plot
        figure(1); clf; 
        subplot(121);
        show_annotation(a, V);
        subplot(122);
        show_annotation(ac,V);
        pause
    end
    A = A.push(ac);
end

%% View them
if debug_plot
    for i = 1:length(A)
        a = A.get(i);
        figure(1); clf;
        show_annotation(a, V);
        pause;
    end
end