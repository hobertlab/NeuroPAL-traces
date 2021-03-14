classdef LazyArray < ArrayBase
    % LAZYARRAY Lazily evaluated immutable array.
    %
    % Author: Vivek Venkatachalam (vivekv2@gmail.com)

    properties (SetAccess = immutable)

        Preimage

        PreimageSize

        % Access function, or cell array of access functions for each
        % slice. If a cell array is provided, the image for each slice must
        % be of the same shape.
        Lambda
        
        % Additional arguments to be sent to the slice access function.
        LambdaArgs = {}

        % Always the last dimension
        SlicedDimension

        NSlices

    end

    methods

        function obj = LazyArray(array, slice_function, args)
            % y = LAZYARRAY(x, slice_function)
            %
            %   Read-only array that applies an access function to x.
            %
            %     x: d-dimensional array of size [Sx, NSlices], which will
            %       be sliced and processed along its last dimension.
            %
            %     slice_function: takes in an array with d-1 dimensions and
            %       returns an array of fixed size Sy.
            %
            %   Subsequently, y(...) will index into a new array of size
            %   [Sy, NSlices], with processing occuring on the fly (lazily)
            %
            %   To cache the result of this computation, consider putting
            %   the output in a CachedArray.

            obj.Preimage = array;
            obj.PreimageSize = size(obj.Preimage);
            obj.Lambda = slice_function;
            
            if nargin > 2
                obj.LambdaArgs = args;
            end

            preimage_size = size(obj.Preimage);
            obj.NSlices = preimage_size(end);

            sample_slice = obj.get_slice(1);
            obj.Size = [size(sample_slice) obj.NSlices];
            obj.SlicedDimension = length(obj.Size);
            obj.ElementClass = element_class(sample_slice);

        end

        function [varargout] = subsref(this, S)

            % Determine which slices we will need to transform
            requested = S.subs{this.SlicedDimension};

            data = zeros([this.Size(1:end-1) length(requested)], ...
                this.ElementClass);

            idx = num2cell(repmat(':', 1, length(this.Size)));
            for i = 1:length(requested)

                idx{end} = i;
                data(idx{:}) = this.get_slice(requested(i));

            end

            new_S = S;
            new_S.subs{this.SlicedDimension} = ':';
            varargout{1} = subsref(data, new_S);

        end

        function data = get_slice(this, t)

            assert(numel(t)==1, ...
                'get_slice can only be called on single slices');

            idx = num2cell(repmat(':', 1, length(this.PreimageSize)));
            idx{end} = t;

            preimage_slice = subsref(this.Preimage, ...
                struct('type', '()', 'subs', {idx}));

            if ~iscell(this.Lambda)
                f = this.Lambda;
            else
                f = this.Lambda{t};
            end
            
            if length(this.LambdaArgs) ~= this.NSlices 
                args = this.LambdaArgs;
            else
                args = this.LambdaArgs{t};
            end
            
            data = f(preimage_slice, args{:});

        end

        function array = get_preimage(this)
            array = this.Preimage;
        end

    end

end
