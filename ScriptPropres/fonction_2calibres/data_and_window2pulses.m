function [pulse_e,pulse_r] = data_and_window2pulses(data,window_choice,nb_sat_e,nb_sat_r, plot_on)
    %DATA_AND_WINDOW2PULSES Cette fonction prends les data issues de
    %files2struct_2calibres pour extraire les pulses :
    % on prends nb_sat_e-1
    %                       dans l emeteur calibre 1 le reste dans calibre 2. 
    %            nb_sat_r   pour le recepteur calibre 1 et le reste dans calibre 2
    %   Detailed input
    %            data : issue de files2struct_2calibres
    %            window_choice : choix de la fenetre parmis
    %                            "rect"
    %           plot_on ploter
    
    % le signal 
    S_ec1 = data.emeteur.c1;
    S_ec2 = data.emeteur.c2;
    S_rc1 = data.recepteur.c1;
    S_rc2 = data.recepteur.c2;
    %
    pic_id_ec1 = data.pics.emeteur.c1.pic_id;
    pic_id_ec2 = data.pics.emeteur.c2.pic_id;
    pic_id_rc1 = data.pics.recepteur.c1.pic_id;
    pic_id_rc2 = data.pics.recepteur.c2.pic_id;
    
    % size_pulse_e = nb_sat_e-1 + length(pic_id_ec2);
    % size_pulse_r = nb_sat_r + length(pic_id_rc2);

    if window_choice == "rect"
        if nb_sat_e-1>1 % s il y a plus d un pulse on est bon
            [pulse_e_c1] = fenetre_rect(S_ec1,pic_id_ec1(1:(nb_sat_e-1)),plot_on);% on prend les pulses saturé sauf le premier pic
        else
            ind_fin_pic1 = floor( (pic_id_ec2(1)+pic_id_ec1(1))/2 );
            [pulse_e_c1] = fenetre_rect(S_ec1,pic_id_ec1(1:(nb_sat_e-1)),plot_on,ind_fin_pic1);% on donne à la fonction ce dont elle a besoin
        end
        [pulse_e_c2] = fenetre_rect(S_ec2,pic_id_ec2,plot_on);% le reste des plot
        pulse_e = [pulse_e_c1,pulse_e_c2];
        % recepteur
        if nb_sat_r>1 % s il y a plus d un pulse on est bon
            [pulse_r_c1] = fenetre_rect(S_rc1,pic_id_rc1(1:nb_sat_r),plot_on);% on prend les pulses saturés
        else
            ind_fin_pic1 = floor( (pic_id_rc2(1)+pic_id_rc1(1))/2 );
            [pulse_r_c1] = fenetre_rect(S_rc1,pic_id_rc1(1:nb_sat_r),plot_on,ind_fin_pic1);% on donne à la fonction ce dont elle a besoin
        end
        [pulse_r_c2] = fenetre_rect(S_rc2,pic_id_rc2,plot_on);% le reste des plot
        pulse_r = [pulse_r_c1,pulse_r_c2];
    else
        error("window_choice non valide")
    end

    % pulse_e = ;
end

