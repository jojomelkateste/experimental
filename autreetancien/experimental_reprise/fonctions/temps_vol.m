function [v_array] = temps_vol(pic_time_e,pic_time_r,e)
    %TEMPS_VOL Calcul du temps de vol 
    % pic_time_e pic des emeteurs
    % pic_time_r pic des recepteur
    % e eppaisseur parcouru 
    d = 2*e;
    v0 = e./(pic_time_r(1)-pic_time_e(1)); % le premier trajets
    try 
    v_array_1 = d./(pic_time_e(2:end)-pic_time_e(1:end-1)); 
    catch 
        disp("Warning moins deux deux pic emetteur")% les trajet retour
        v_array_1 = [];
    end 

    % idem avec les signal recepteur 
    try
        v_array_2 = d./(pic_time_r(2:end)-pic_time_r(1:end-1)); % les trajet alle
    catch 
        v_array_2 = [];
        disp("Warning moins deux deux pic recepteur")% les trajet retour
    end
    v_array = [v0,v_array_1,v_array_2];
end