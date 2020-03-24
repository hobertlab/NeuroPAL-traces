function stimulus = get_stimulus(stimulus_filename)

fileID = fopen(stimulus_filename,'r');
formatSpec = '%s %f';
text_data = textscan(fileID,formatSpec,'HeaderLines',3,'Delimiter','\t');
fclose(fileID);

text_length = length(text_data{1});
odors = text_data{1}(2:2:text_length); % odor names
odor_times = cumsum(text_data{2}); % odor ON and odor OFF times
odor_ON = odor_times(1:2:text_length); % includes end time (last element)
odor_OFF = odor_times(2:2:text_length);

odor_frames_ON = round(odor_ON);
odor_frames_OFF = round(odor_OFF);

stimulus = cell(length(odors),3);
for i = 1:length(odors)
stimulus(i,:) = {odors{i}, odor_frames_ON(i), odor_frames_OFF(i)};
end
