function [ue_c1,ue_c2,ur_c1,ur_c2,freq,temps] = lire_2calibres(name1,name2,rm_noise)
    %LIRE_2CALIBRES Summary of this function goes here
    %   Detailed explanation goes here
    arguments (Input)
        name1
        name2
        rm_noise = true
    end
    
    % nomenclature 
    % e: emeteur 
    % r: recepteur
    % c1: calibre1
    % c2: calibre2
    % calibre 1
    S1 = load(name1);
    srce_c1 = S1.src1; % emeteur
    srcr_c1 = S1.src2; % recepteur 
    %autre info
    % autre info 
    fe = srce_c1.SampleFrequency;
    
    N = length(srce_c1.Data);
    temps = (0:(N-1))/fe; % temps 
    freq = (-N/2:N/2-1)*(fe/N);
    %retour aux data
    
    ue_c1 = srce_c1.Data;  %champ de deplacement calibre 1
    ur_c1 = srcr_c1.Data;

    S2 = load(name2);
    srce_c2 = S2.src1; % emeteur
    srcr_c2 = S2.src2; % recepteur 
    
    ue_c2 = srce_c2.Data;    %champ de deplacement calibre 2
    ur_c2 = srcr_c2.Data; 
    if rm_noise
         ue_c1 = remove_noise_bis(ue_c1,freq,fe);
         ur_c1 = remove_noise_bis(ur_c1,freq,fe); 
         ue_c2 = remove_noise_bis(ue_c2,freq,fe);
         ur_c2 = remove_noise_bis(ur_c2,freq,fe);
    end

end