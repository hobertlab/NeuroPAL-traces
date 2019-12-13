animal = "0928_01";
part = "head";
id_path = "path\to\id_file";
id_run = "id101_ID.mat";
gcamp_path = "path\to\gcamp_nd2_movie";
gcamp_run = "run101.nd2";
data_path = "path\to\output";

row = table(animal, part, id_path, id_run, gcamp_path, gcamp_run, data_path);
%%

row = preprocess_video(row);
row = get_ID_annotations(row);
row = get_traces(row);
