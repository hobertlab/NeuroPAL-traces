animal = "1_01";
part = "head";
id_path = "E:\Helena OH16230";
id_run = "id201_ID.mat";
gcamp_path = "E:\Helena OH16230";
gcamp_run = "run201.nd2";
data_path = "E:\Helena OH16230\Data_Output";

row = table(animal, part, id_path, id_run, gcamp_path, gcamp_run, data_path);
%%

row = preprocess_video(row);

%%
row = get_ID_annotations(row);
row = get_traces(row);
