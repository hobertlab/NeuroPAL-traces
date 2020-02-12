classdef Annotation
    %ANNOTATION This describes a single point annotation in a 3D volume.

    properties
        position
        time
        worldline_id
        confidence
        parent_id
        id
    end

    methods
        function obj = Annotation(yxz_position, time, worldline_id, ...
                confidence, parent_id, id)

            if nargin < 5
                parent_id= [];
            end
            
            if nargin < 6
                id = get_id(9);
            end

            obj.position = yxz_position;
            obj.time = time;
            obj.worldline_id = worldline_id;
            obj.confidence = confidence;
            obj.parent_id = parent_id;

            obj.id = id;

        end
        
        function y = clone_child(obj)
            y = obj;
            y.id = get_id(9);
            y.parent_id = obj.id;
        end
        
        function y = to_annotator_struct(obj, dataset_id, sz, scale)
            
            translate_coord = @(x, max, scale) (x-1)*(scale*max)/(max-1);
            
            annotator_id = sprintf('%s_%d_%d', ...
                dataset_id, obj.worldline_id, obj.time);
            d = obj.position;
            
            neuron_id = sprintf('Q%3d', obj.worldline_id + 100);
            
            y = struct(...
                'id', annotator_id, ...
                'dataset_id', dataset_id, ...
                'neuron_id', neuron_id, ...
                'x', translate_coord(d(2), sz(2), scale(2)), ...
                'y', translate_coord(d(1), sz(1), scale(1)), ...
                'z', translate_coord(d(3), sz(3), scale(3)), ...
                'c', 0, ...
                't', obj.time, ...
                'confidence', obj.confidence, ...
                'trace', []);
            
        end
    end

end

