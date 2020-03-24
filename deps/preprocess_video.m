function preprocess_video(hdf5_filename, new_filename)

X = HDF5Array(hdf5_filename, '/data');
S = size(X);
size_T = S(4);

h5create(new_filename, '/data', S, 'Datatype', 'uint8', ...
    'Deflate', 5, 'ChunkSize', [S(1:3), 1]);

b = bump_detector([3 3 .5], [15 15 3], [15, 15, 3]);
smooth = @(x) convn(double(x), b, 'same');

batch = smooth(X(:,:,:,1:100));

lo = double(quantile(batch(:), 0.9));
hi = double(quantile(batch(:), 0.99999))*1.5;

make_uint8 = @(x) uint8((double(x)-lo)/(hi-lo)*255);

for t = 1:size_T
    t
    x = smooth(get_slice(X, t));
    y = make_uint8(x);
    pause(0.01);
    h5write(new_filename, '/data', y, [1 1 1 t], [S(1:3) 1]);
end
