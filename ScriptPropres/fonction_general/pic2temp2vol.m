function [v_array,ki,ki_err] = pic2temp2vol(pic,pic_index,temps,e)
    % PIC2TEMP2VOL prend en parametre la liste des pic d un signal, la liste des
    % temps et la liste des indice des pics pour donner vg, attentuation par
    % temps de vol
    %   Detailed explanation goes here
    % Calcul du temps de vol
    d = 2*e;
    pic_times = temps(pic_index);
    v_array =  d./(pic_times(2:end)-pic_times(1:end-1)); 
    
    % Calcul du facteur d'attenuation avec les pics
    d_pic = 2*e*(1:length(pic_times));
    [p,S] = polyfit(d_pic, log(pic), 1);
    ki = - p(1);
    ki_err = S;
end

