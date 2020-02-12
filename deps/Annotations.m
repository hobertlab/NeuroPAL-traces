classdef Annotations
    %ANNOTATION This describes a collection of Annotation objects.

    properties
        Table
    end

    methods
        
        function obj = Annotations(t)
            obj.Table  = cell2table(cell(0,6), 'VariableNames', ...
                {'position', 'time', 'worldline_id', 'confidence', ...
                'parent_id', 'id'});
            if nargin == 1
                obj.Table = [obj.Table; t];
            end
        end
        
        function obj = push(obj, a)
            if ~isempty(a)
                idx = size(obj.Table, 1) + 1;
                obj.Table = [obj.Table; {a.position, a.time, ...
                    a.worldline_id, a.confidence, a.parent_id, a.id}];
                obj.Table.Properties.RowNames{idx} = a.id;
            end
        end
        
        function obj = cat(obj, A)
            try
                obj.Table = [obj.Table; A.Table];
            catch e
                switch e.identifier
                    case 'MATLAB:table:DuplicateRowNames'
                        A = remove_duplicate_ids(A, obj);
                        obj = cat(obj, A);
                    otherwise
                        rethrow(e);
                end
            end
        end

%         function obj = cat(obj, A)
%             obj.Table = [obj.Table; A.Table];
%         end
        
        function a = get(obj, a_id)
            a = table2cell(obj.Table(a_id,:));
            a = Annotation(a{:});
        end
        
        function a = get_rows(obj, idx)
            a = Annotations(obj.Table(idx,:));
        end
        
        function obj = remove(obj, a_id)
            obj.Table(a_id,:) = [];
        end
        
        function subset = filter(obj, f)
            t = obj.Table(f(obj.Table),:);
            subset = Annotations(t);
        end
        
        function y = get_t(obj, t)
            y = obj.filter(@(x) x.time==t);
        end
        
        function y = get_worldline(obj, w)
            y = obj.filter(@(x) x.worldline_id==w);
        end
        
        function y = get_best(obj)
            scores = obj.Table.confidence;
            scores(isnan(scores)) = 0;
            obj.Table.confidence = scores;
            best = max_all(scores);
            best_annotations = obj.filter(@(x) x.confidence==best);
            if length(best_annotations) > 0
                y = best_annotations.get(1);
            else
                y = [];
            end
        end
        
        function y = consolidate_best(obj)
            worldlines = obj.worldlines();
            times = obj.times_set();
            y = Annotations();
            for t = row(times)
                for w = row(worldlines)
                    a = obj.get_t(t).get_worldline(w).get_best();
                    y = y.push(a);
                end
            end
        end
        
        function y = positions(obj)
            y = obj.Table.position;
        end
        
        function y = worldlines(obj)
            y = unique(obj.Table.worldline_id);
        end
        
        function y = time(obj)
            y = obj.Table.time;
        end
        
        function y = times_set(obj)
            y = unique(obj.Table.time);
        end
        
        function y = confidence(obj)
            y = obj.Table.confidence;
        end
        
        function [y, vals] = find_nearest(obj, id, N)
            src = column(obj.get(id).position);
            
            others = obj.remove(id);
            tgt = others.positions()';
            
            [idx, vals] = find_nearest(src, tgt, N);
            
            y = others.get_rows(idx);
            
        end
        
        function disp(obj)
            disp(obj.Table)
        end
        
        function y = size(obj, varargin)
            y = size(obj.Table, varargin{:});
        end
        
        function y = length(obj)
            y = size(obj, 1);
        end
        
        function to_annotator_json(this, dataset_id, sz, scale, filename)
            if exist(filename, 'file')
                current_annotations = load_json(filename);
            else
                current_annotations = struct();
            end

            new_annotations = struct();
            for i = 1:length(this)
                a = this.get(i);
                a_struct = a.to_annotator_struct(dataset_id, sz, scale);
                new_annotations.(a_struct.id) = a_struct;
            end
            
            y = merge_struct(current_annotations, new_annotations);
            save_json(y, filename);

        end
        
    end
    
    methods (Static)
        
        function obj = from_annotator_json(filename, dataset_id, sz, scale)
            
            json_annotations = load_json(filename);
            fns = fieldnames(json_annotations);
            
            obj = Annotations();
                        
            translate_coord = @(x, max, scale) x/(scale*max)*(max-1)+1;
            ty = @(y) translate_coord(y, sz(1), scale(1));
            tx = @(y) translate_coord(y, sz(2), scale(2));
            tz = @(y) translate_coord(y, sz(3), scale(3));
            
            for i = 1:length(fns)
                if strcmp(json_annotations.(fns{i}).dataset_id, dataset_id)
                    j = json_annotations.(fns{i});
                    worldline_id = sscanf(j.neuron_id, 'Q%3d') - 100;
                    a = Annotation([ty(j.y), tx(j.x), tz(j.z)], j.t, ...
                        worldline_id, j.confidence);
                    obj = obj.push(a);
                end
            end
            
        end
        
    end
end

