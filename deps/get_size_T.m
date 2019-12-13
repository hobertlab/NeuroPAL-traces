function size_T = get_size_T(F)
% size_T = get_size_T(directory)
%
%   Returns the size of the time-dimension of a matfile or tif directory.

if isa(F, 'char') && exist(F, 'dir') % TIF directory
    size_T = length(dir(fullfile(F, 'T_*')));
    if size_T == 0
        features = load_features(F);
        size_T = size(features{1}.coordinates, 1);
    end
    return
end

if isa(F, 'matlab.io.MatFile')
    mfile = F;
    vars = whos(mfile);
    size_T = vars(1).size(end);
    return
end

if isa(F, 'char')
    mfile = matfile(F);
    vars = whos(mfile);
    size_T = vars(1).size(end);
    return
end

if isa(F, 'struct') && isfield(F, 'coordinates')
    size_T = size(F.coordinates, 1);
end

if isnumeric(F) || isa(F, 'TIFFArray') || isa(F, 'LazyArray') || ...
        isa(F, 'CachedArray') || isa(F, 'MatfileArray')
    
    s = size(F);
    size_T = s(end);
    return

end

s = size(F);
size_T = s(end);
