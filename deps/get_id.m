        function id = get_id(N)
        % id = GET_ID(N)
        %
        %   Return N random alphanumeric characters (alphabet size: 55)
        symbols = [...
        'abcdefghijkmnpqrstuvwxyz', ...
        '23456789', ...
        'ABCDEFGHJKLMNQRSTUVWXYZ'];
        id = symbols(randi(length(symbols), N, 1));
        end