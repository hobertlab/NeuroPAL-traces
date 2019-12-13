classdef ArrayBase < handle
    %ARRAYBASE Shared behavior of custom arrays.
    %
    % Author: Vivek Venkatachalam (vivekv2@gmail.com)

    properties

        Size

        ElementClass

    end

    methods
                
        function y = get(this, prop)
            y = this.(prop);
        end

        function s = size(obj, d)
            s = obj.Size;
            
            if nargin > 1
                if d <= length(s)
                    s = s(d);
                else
                    s = 1;
                end
            end
        end

        function n = numel(this)
            n = prod(this.Size);
        end

        function n = ndims(this)
            n = length(this.Size);
        end

        function t = element_class(this)
            t = this.get('ElementClass');
        end
        
        function y = isarray(~)
            y = true;
        end


    end

end

