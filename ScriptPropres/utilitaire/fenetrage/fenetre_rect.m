function [pulse_array] = fenetre_rect(S,pic_indexes,plot_on,ind_fin_pic1)
    %FENETRE_RECT_2CALIBRE Cette fonction extrait d un signal S dont on
    %connait les pics pic_index 
    %   Detailed explanation goes here
    arguments
        S 
        pic_indexes 
        plot_on = false
        ind_fin_pic1  = 0 % parametre utilise s il y a qu un pic on donne sa taille en indice
    end
    Ls = length(S); % longeur du signal 
    if isempty(pic_indexes)
        pulse_array = {};
    elseif isscalar(pic_indexes)
        pulse = zeros(1,Ls);
        pulse(1:ind_fin_pic1) = S(1:ind_fin_pic1);
        pulse_array = {pulse};
        if plot_on 
            figure; plot(S); hold on;
            plot(pulse,"r")
        end  
    else

        % Trouver le premier indice
        dN = pic_indexes(2)-pic_indexes(1); % nombre de point dans un pic
        i_deb = pic_indexes(1)-floor(dN/2);

        if i_deb<1
            i_deb=1; % on part du début
        end
        %% inspiration
    
        N_pic = length(pic_indexes);
        % recupération grossierre des pulses
        pulse_array = cell(1,N_pic);
        %i_fin = int((pic_indexes(2)-pic_indexes(1))/2); % on suppose qu il y a au moins deux pulses et donc deux pic
        for n=1:N_pic-1
            i_fin = floor((pic_indexes(n+1)+pic_indexes(n))/2);
            pulse = zeros(1,length(S));
            pulse(i_deb:i_fin) = S(i_deb:i_fin); % on selectionne la zone
            pulse_array{n} = pulse;
            i_deb = i_fin;
        end
        % dernier pulse
        dN = pic_indexes(end)-pic_indexes(end-1); % on recalcule le dN a cet endroit la
        i_fin = pic_indexes(end)+floor(dN/2);
        if i_fin>Ls
            i_fin = Ls;
        end
        pulse = zeros(1,length(S));
        pulse(i_deb:i_fin) = S(i_deb:i_fin); % on selectionne la zone
        pulse_array{N_pic} = pulse;
        
        % Afffichage pour vérifier
        if plot_on
            figure;
            h_btn = uicontrol('Style', 'pushbutton', ...
                    'String', 'Continuer', ...
                    'Position', [20 20 100 30], ... % En bas à gauche [x y largeur hauteur]
                    'Callback', 'uiresume(gcbf)');   % Commande pour relancer l'exécution
            plot(S);
            hold on;
            for i=1:N_pic
                plot(pulse_array{i},"r--")
                uiwait(gcf);
                hold off;
                plot(S);
                hold on;
            end
            
        end
    end
end