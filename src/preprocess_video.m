function row = preprocess_video(row)

gcamp_path = row.gcamp_path{1};
gcamp_file = row.gcamp_run{1};
id_file = fullfile(row.id_path, row.id_run);
data_path = row.data_path{1};

make_directory(data_path);

gcamp_file_mat = fullfile(data_path, 'data.mat');
gcamp_file_mov = fullfile(data_path, 'movie.mp4');
annotations_file = fullfile(data_path, 'annotations.mat');

b = bump_detector([1 1 0.5], [5 5 3], [7, 7, 3]);
smooth = @(x) convn(double(x), b, 'same');

id_vol_file = join([extractBefore(id_file, "_ID.mat"), ".mat"], "");

V = load(id_vol_file);

id_gcamp_16 = get_slice(V.data, 4);
lo = double(quantile(id_gcamp_16(:), 0.9));
hi = double(quantile(id_gcamp_16(:), 0.9999));

size_Z = size(id_gcamp_16, 3);

id_gcamp = uint8((double(id_gcamp_16)-lo)/(hi-lo)*255);
id_gcamp = imresize3(id_gcamp, [128, 256, size_Z]);
id_gcamp = uint8(smooth(id_gcamp));
id_gcamp_flip = flip(flip(id_gcamp, 3), 1);

B_ref = BioFormatsArray(char(fullfile(gcamp_path, gcamp_file)));
raw_times = get_times(B_ref);
B = get_array_data(B_ref);
data_gcamp = squeeze(B);

clear B B_ref;

size_Z = size(id_gcamp, 3);
template = double(column(max_intensity_x(id_gcamp)));
template_flip = double(column(max_intensity_x(id_gcamp_flip)));
data_template = double(max_intensity_x(data_gcamp));
offsets = [1:size(data_template, 2)-size_Z];

score = zeros(size(offsets));
score_flip = zeros(size(offsets));
for i = offsets
    section = column(data_template(:, i : i+size_Z-1));
    r = corrcoef(section, template);
    r_flip = corrcoef(section , template_flip);
    score(i) = r(1,2);
    score_flip(i) = r_flip(1,2);
end

flip_id = false;
if max_all(score) < max_all(score_flip)
    flip_id = true;
    score = score_flip;
end

threshold = 0.6*max_all(score);
[pks, loc] = findpeaks(score);
good_loc = loc(pks>threshold);
good_loc_1 = good_loc(1);
spacings = diff(good_loc);
med_spacing = median(spacings);

bad = find(spacings ~= med_spacing);
for i = 2:length(bad)
    if abs(bad(i)-bad(i-1))<=1
        if (spacings(bad(i))+spacings(bad(i-1)))/2 == med_spacing
            spacings(bad(i)) = med_spacing;
            spacings(bad(i-1)) = med_spacing;
        end
    end
end
good_loc = good_loc_1 + cumsum(spacings);


size_T = length(good_loc);
times = raw_times(good_loc + size_Z - 1);
data_3D_gcamp = zeros([size(id_gcamp), size_T], 'like', data_gcamp);

for i = 1:length(good_loc)
    s = good_loc(i);
    data_3D_gcamp(:,:,:,i) = data_gcamp(:,:,s:s+size_Z-1);
end

if flip_id
    data_3D_gcamp = flip(flip(data_3D_gcamp, 1), 3);
end

batch = smooth(data_3D_gcamp(:,:,:,1:100));
lo = double(quantile(batch(:), 0.9));
hi = double(quantile(batch(:), 0.99999))*1.5;

make_uint8 = @(x) uint8((double(x)-lo)/(hi-lo)*255);

data_temp = smooth(double(data_3D_gcamp));
gcamp_movie = make_uint8(data_temp);

data = cat(4, id_gcamp, gcamp_movie);

id_data = V;
save(gcamp_file_mat, 'data', 'id_data');

S = load(id_file);

size_N = length(S.neurons.neurons);
row.neurons = size_N;

annotations_id = Annotations();

for i = 1:size_N
    yxz = [S.neurons.neurons(i).position(1)/2 + 0.5, ...
        S.neurons.neurons(i).position(2)/2 + 0.5, ...
        S.neurons.neurons(i).position(3)];
    
    a = Annotation(yxz, 1, i, 0.99);
    annotations_id = annotations_id.push(a);
end

A = annotations_id;

save(annotations_file, 'A');

stimulus_file = fullfile(gcamp_path, [gcamp_file(1:end-3) 'txt']);
stimulus_seconds = get_stimulus(stimulus_file);

input_neurons = S.neurons.neurons;
metadata_file = fullfile(row.data_path, 'metadata.mat');
save(metadata_file, 'input_neurons', 'stimulus_seconds', 'times');
