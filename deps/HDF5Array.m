classdef HDF5Array < ArrayBase
    %HDF5ARRAY Provides lazy reading of HDF5 files.
    % Author: Vivek Venkatachalam (vivekv2@gmail.com)

    properties (SetAccess = immutable)

        % File to read
        Filename

        % Field in matfile this array will access.
        Field

    end

    methods

        function obj = HDF5Array(filename, field)

            obj.Filename = filename;
            obj.Field= field;

            metadata = h5info(obj.Filename);

            dataset_path = strsplit(field, '/');
            dataset_name = dataset_path{end};

            meta = NaN;
            for i = 1:length(metadata.Datasets)
                if strcmp(metadata.Datasets(i).Name, dataset_name)
                    meta = metadata.Datasets(i);
                end
            end

            if ~isstruct(meta)
                error('Field not found');
            end

            obj.Size = meta.Dataspace.Size;

            h5type = meta.Datatype.Type;

            if strcmp(h5type, 'H5T_STD_U16LE')
                mat_type = 'uint16';
            elseif strcmp(h5type, 'H5T_IEEE_F64LE')
                mat_type = 'double';
            elseif strcmp(h5type, 'H5T_STD_U8LE')
                mat_type = 'uint8';
            else
                error('%s not a recognized type. Add it!', h5type);
            end

            obj.ElementClass = mat_type;

        end

        function [varargout] = subsref(this, S)

            for i = 1:length(S.subs)
                if isnumeric(S.subs{i})
                    idx{i} = [min(S.subs{i}):max(S.subs{i})];
                    idx_start(i) = idx{i}(1);
                    idx_size(i) = numel(idx{i});

                    s{i} = S.subs{i} - min(S.subs{i}) + 1;
                else
                    idx{i} = S.subs{i};
                    idx_start(i) = 1;
                    idx_size(i) = this.Size(i);

                    s{i} = ':';
                end
            end

            A = h5read(this.Filename, this.Field, idx_start, idx_size);

            varargout{1} = A(s{:});

        end

    end

end

