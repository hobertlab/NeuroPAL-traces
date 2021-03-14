function x = clip_coordinates(x, sz)

x = max(x, ones(size(x)));
x = min(x, sz);