function [res] = my_cell2array(cell_list)
    %MY_CELL2ARRAY prend une cell list de list normal (qui ont toute la meme longueur) et la transforme en
    %matrice
    %   Detailed explanation goes here
    nl = length(cell_list); % nb de ligne
    nc = length(cell_list{1}); % nb de collone
    res = zeros(nl,nc);
    for i=1:nl
        a = cell_list{i};
        if not(length(a)==nc)
            error("invalid data")
        end
        res(i,:)=a;
    end
end

