function [pulse_array] = fenetre_rect(S,pic_indexes,plot_on)
    %FENETRE_RECT_2CALIBRE Cette fonction extrait d un signal S dont on
    %connait les pics pic_index 
    %   Detailed explanation goes here
    arguments
        S 
        pic_indexes 
        plot_on = false
    end
    
    Ls = length(S); % longeur du signal 
    % Trouver le premier indice
    dN = pic_indexes(2)-pic_indexes(1); % nombre de point dans un pic
    i_deb = pic_indexes(1)-dN;
    if i_deb<1
        i_deb=1; % on part du début
    end
    %% inspiration

    N_pic = length(pic);
    % recupération grossierre des pulses
    pulse_array = cell(1,N_pic);
    i_deb = 1;
    %i_fin = int((pic_indexes(2)-pic_indexes(1))/2); % on suppose qu il y a au moins deux pulses et donc deux pic
    for n=1:N_pic-1
        i_fin = floor((pic_indexes(n+1)+pic_indexes(n))/2);
        pulse = zeros(1,length(S));
        pulse(i_deb:i_fin) = S(i_deb:i_fin); % on selectionne la zone
        pulse_array{n} = pulse;
        i_deb = i_fin;
    end
    % dernier pulse
    i_fin = pic_indexes(end)+dN;
    if i_fin>Ls
        i_fin = Ls;
    end
    pulse = zeros(1,length(S));
    pulse(i_deb:end) = S(i_deb:i_fin); % on selectionne la zone
    pulse_array{N_pic} = pulse;
    
    % Afffichage pour vérifier
    if plot_on
        figure;
        plot(S);
        for i=1:N_pic
            plot(pulse_array{i},"r--")
        end
    end
end