function [output] = files2struct_2calibres(name_c1,name_c2,nb_sat_e,nb_sat_r,MinPeakDistance,MinPeakHeight1,MinPeakHeight2)
    %signal2pulses_2calibres Prend les path vers 2 signaux de calibre
    %different et renvoie la liste des pulses intéressant à savoir le
    %premier pulse par le premier calibre (ou les deux premiers selon la valeur de nb_sat), 
    % et les autre par le second calibre. Ce pour le signal emis et pour le signal recu
    %   Renvoie  la liste des frequences des temps et les array des pulses
    %   recupere avec une fenetre rectangulaire simple, en tout cas pour le
    %   moment
    arguments (Input)
        name_c1 % calibre 1 dezoome
        name_c2 % calibre 2 zoom
        nb_sat_e = 1 % nombre de pics satures pour l emeteur dans le calibre 2
        nb_sat_r = 1 % nombre de pics satures pour l emeteur dans le calibre 2
        MinPeakDistance =  -1 % pour trouver les pics distence minimum qui les sépare
        MinPeakHeight1  = 0.004
        MinPeakHeight2  = 0.004
    end
    % MinPeakDistance == -1 n applique pas MinPeakDistance
    % Lecture des datas
    [ue_c1,ue_c2,ur_c1,ur_c2,freq,temps] = lire_2calibres(name_c1,name_c2);
    % On détecte les enveloppe du calibre 1 dezoome
    % Les enveloppes
    envelope_e_c1 = abs(hilbert_maison(ue_c1));
    envelope_r_c1 = abs(hilbert_maison(ur_c1));
    % les pic detectes
    if MinPeakDistance>0
        [pic_ec1,id_pic_ec1]  = findpeaks_maison(envelope_e_c1,'MinPeakHeight', MinPeakHeight1,'MinPeakDistance', MinPeakDistance);
        [pic_rc1,id_pic_rc1]  = findpeaks_maison(envelope_r_c1,'MinPeakHeight', MinPeakHeight2,'MinPeakDistance', MinPeakDistance);
    else
        [pic_ec1,id_pic_ec1]  = findpeaks_maison(envelope_e_c1,'MinPeakHeight', MinPeakHeight1);%,'MinPeakDistance', MinPeakDistance);
        [pic_rc1,id_pic_rc1]  = findpeaks_maison(envelope_r_c1,'MinPeakHeight', MinPeakHeight2);%,'MinPeakDistance', MinPeakDistance);
    end
    pic_time_ec1 = temps(id_pic_ec1);pic_time_ec1 = pic_time_ec1(:);
    pic_time_rc1 = temps(id_pic_rc1);pic_time_rc1 = pic_time_rc1(:);
    % Detection de l enveloppe pour le cas dezoom en enlevant le 1er pic
    % qui est saturé
    % On essaye enleve d'abord le pic ecrasée
    try 
        pulse_duration = pic_time_ec1(2)-pic_time_ec1(1) ; % c est cette ligne qui risque de planter d ou le try 
        %  pulse emeteur
        ue_c2_bis = ue_c2;                                 % on copie le signal
        t_max = pic_time_ec1(nb_sat_e)+pulse_duration/2;  % on repere le premier pic a l aide de l autr calibre
        [~,index_max] = min(abs(temps-t_max));     % indice pour le temps qui correspond au t_max
        ue_c2_bis(1:index_max) = 0;                % On elimine cette partie de la copie du signal
        envelope_e_c2 = abs(hilbert_maison(ue_c2_bis));   % detection de l'enveloppe
        % pulse recepteur
        pulse_duration = pic_time_rc1(2)-pic_time_rc1(1) ;
        t_max = pic_time_rc1(nb_sat_r)+pulse_duration/2;
        [~,index_max] = min(abs(temps-t_max)); 
        ur_c2_bis = ur_c2;                                 % on copie le signal
        ur_c2_bis(1:index_max) = 0;                % On elimine cette partie de la copie du signal
        envelope_r_c2 = abs(hilbert_maison(ur_c2_bis));   % detection de l'enveloppe
        
    catch err
        % A FAIRE: Demander d entrer le pulse_duration ou de continuer comme si
        % de rien ete pour trouver ce temps relancer le code et l ecrire
        disp("catch de l erreur")
        envelope_e_c2 = abs(hilbert_maison(ue_c1));
        envelope_r_c2 = abs(hilbert_maison(ur_c1));
    end
    
    % La on trouve les pics pour le calibre zoom, abstraction faite du
    % premier pic probablement saturé
    if MinPeakDistance>0
        [pic_ec2,id_pic_ec2]  = findpeaks_maison(envelope_e_c2,'MinPeakHeight', MinPeakHeight1,'MinPeakDistance', MinPeakDistance);
        [pic_rc2,id_pic_rc2]  = findpeaks_maison(envelope_r_c2,'MinPeakHeight', MinPeakHeight2,'MinPeakDistance', MinPeakDistance);
    else
        [pic_ec2,id_pic_ec2]  = findpeaks_maison(envelope_e_c2,'MinPeakHeight', MinPeakHeight1);%,'MinPeakDistance', MinPeakDistance);
        [pic_rc2,id_pic_rc2]  = findpeaks_maison(envelope_r_c2,'MinPeakHeight', MinPeakHeight2);%,'MinPeakDistance', MinPeakDistance);
    end

    pic_time_ec2 = temps(id_pic_ec2);pic_time_ec2 = pic_time_ec2(:); % transformation en vecteur collone
    pic_time_rc2 = temps(id_pic_rc2);pic_time_rc2 = pic_time_rc2(:);
    %% Affichage des 4 signaux et on vérifie les pics  
    figure;
    subplot(2,2,1)
    plot(temps,ue_c1)
    hold on;
    plot(temps,envelope_e_c1)
    scatter(pic_time_ec1,pic_ec1)
    title("Emeteur calibre 1")
    
    subplot(2,2,2)
    plot(temps,ur_c1)
    hold on;
    plot(temps,envelope_r_c1)
    scatter(pic_time_rc1,pic_rc1)
    title("Recepteur calibre 1")
    
    subplot(2,2,3)
    hold on;
    plot(temps,ue_c2)
    plot(temps,envelope_e_c2)
    scatter(pic_time_ec2,pic_ec2)
    title("Emeteur calibre 2")
    
    subplot(2,2,4)
    plot(temps,ur_c2)
    hold on;
    plot(temps,envelope_r_c2)
    scatter(pic_time_rc2,pic_rc2)
    title("Recepteur calibre 2")

    %% Recuperation des pulses

    % les pics concatenes
    % 
    pic_e = pic_ec1(1:nb_sat_e);
    pic_e = [pic_e;pic_ec2];
    pic_e_time = pic_time_ec1(1:nb_sat_e);
    pic_e_time = [pic_e_time;pic_time_ec2];

    pic_e_index = id_pic_ec1(1:nb_sat_e);
    pic_e_index = [pic_e_index;id_pic_ec2];
    % idem pour les reflechis
    pic_r = pic_rc1(1:nb_sat_r);
    pic_r = [pic_r;pic_rc2];
    pic_r_time = pic_time_rc1(1:nb_sat_r);
    pic_r_time = [pic_r_time;pic_time_rc2];

    pic_r_index = id_pic_rc1(1:nb_sat_r);
    pic_r_index = [pic_r_index;id_pic_rc2];
    
    %% creation des outputs
    % info freq et temporels
    output.freq = freq;
    output.temps = temps;
    % On sort aussi le signal entier
    %ue_c1,ue_c2,ur_c1,ur_c2
    output.emeteur.c1 = ue_c1;
    output.emeteur.c2 = ue_c2;
    output.recepteur.c1 = ur_c1;
    output.recepteur.c2 = ur_c2;
    % pic emeteur des deux calibres 
    output.pics.emeteur.c1.pic = pic_ec1;
    output.pics.emeteur.c1.pic_id = id_pic_ec1;
    output.pics.emeteur.c2.pic = pic_ec2;
    output.pics.emeteur.c2.pic_id = id_pic_ec2;
    % pic recepteurs des deux calibres
    output.pics.recepteur.c1.pic = pic_rc1;
    output.pics.recepteur.c1.pic_id = id_pic_rc1;
    output.pics.recepteur.c2.pic = pic_rc2;
    output.pics.recepteur.c2.pic_id = id_pic_rc2;
    % les pic concatenes
    output.pics.pic_concat.pic_e = pic_e;
    output.pics.pic_concat.pic_e_time = pic_e_time;
    output.pics.pic_concat.pic_e_index =pic_e_index;

    output.pics.pic_concat.pic_r = pic_r;
    output.pics.pic_concat.pic_r_time = pic_r_time;
    output.pics.pic_concat.pic_r_index =pic_r_index;
    

    disp("relire pour etre certain des output")
    try % on essaye car pas sur qu on ait 2 pics
        disp("MinPeakDistance sugere prendre 0.5* : "+ (id_pic_rc1(2)-id_pic_rc1(1)))
    end

end