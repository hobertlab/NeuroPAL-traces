classdef ThreeViewArray < LazyArray
    %THREEVIEWARRAY Creates a view of three orthogonal projections from a
    %volume.
    %
    % Author: Vivek Venkatachalam (vivekv2@gmail.com)

    properties (SetAccess = immutable)
        % Sets pixel aspect ratio.
        PixelSize = [1, 1, 2]
    end

    properties (Access = protected)

        % Parent node.
        Root

        % Axes to draw image on.
        Axes

        Initialized = false

    end

    methods

        function obj = ThreeViewArray(array, pixel_size)
            % obj = THREEVIEWARRAY(x)
            %
            %   Creates a view of three orthogonal slices.

            if nargin < 2
                pixel_size = [1, 1, 1];
            end

            obj = obj@LazyArray(array, @ThreeViewArray.combine_MIPs, ...
                {pixel_size});
            
            obj.PixelSize = pixel_size;

        end

    end

    methods (Static)

        function slice = combine_MIPs(a, pixel_size)

            x = max_intensity_x(a);
            y = max_intensity_y(a);
            z = max_intensity_z(a);

            slice = orthoview_from_slices(x, y, z, pixel_size);

        end

    end

end
