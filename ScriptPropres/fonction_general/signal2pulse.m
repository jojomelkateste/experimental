function [pulse_array,pic,id_pic] = signal2pulse(S,MinPeakHeight,options)
    %SIGNAL2PULSE Prend un signal brute, renvoie la liste des pulses
    %  fait une détection d'enveloppe 
    %   Detailed explanation goes here
    arguments (Input)
        S % signal
        MinPeakHeight % seuil pour ne pas détecter le bruit
        options.MinPeakDistance=0 % Distance minimal entre deux pic à entrer pour éviter les faux pics
        options.plot=true % afficher le résultat
        options.plot_pulse=true % afficher les pulse un a un  
    end
    
    arguments (Output)
        pulse_array
        pic
        id_pic
    end
    %recupération des option 
    MinPeakDistance = options.MinPeakDistance;
    %récupération de l'enveloppe
    S_env = abs(hilbert_maison(S));
    if MinPeakDistance>0
        [pic,id_pic]  = findpeaks_maison(S_env,'MinPeakHeight', MinPeakHeight,'MinPeakDistance', MinPeakDistance);
    else
        [pic,id_pic]  = findpeaks_maison(S_env,'MinPeakHeight', MinPeakHeight);%,'MinPeakDistance', MinPeakDistance);
    end
    % On affiche pour affiner
    if options.plot 
        figure;
        hold on; 
        plot(S)
        plot(S_env)
        scatter(id_pic,pic)
    end
    %nb_pulse = length(pic); 
    %pulse_array = cell(1,nb_pulse);
    [pulse_array] = fenetre_rect(S,id_pic,options.plot_pulse ,0);
end