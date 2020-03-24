function s = save_json(obj, filename)
% s = SAVE_JSON(obj, filename)
%
%   Save the data in filename as a matlab object (typically struct)
%
% Author: Vivek Venkatachalam (vivekv2@gmail.com)

chars = jsonencode(obj);

f = fopen(filename, 'w');
chars = fwrite(f, chars);
fclose(f);