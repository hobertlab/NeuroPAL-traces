function s = load_json(filename)
% s = LOAD_JSON(filename)
%
%   Load the data in filename as a matlab object (typically struct);
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

f = fopen(filename);
chars = fread(f, '*char');
fclose(f);

s = jsondecode(chars');