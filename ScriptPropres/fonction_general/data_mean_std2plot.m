function [output] = data_mean_std2plot(file_name,options)
    %DATA_MEAN_STD2PLOT sert a prétraiter les donner pour faire les graphes
    % moyenne ecart type et point par temps de vol
    %   Detailed explanation goes here
    arguments
        file_name 
        options.bool_xlim = true; % pour limiter en fréquences dans l affichage
        options.delta_f_affichage = 0.15e6;
    end
    df = options.delta_f_affichage ;
    bool_xlim = options.bool_xlim;
    

    data = load(file_name);
    data = data.data2save;

    real_fc = data.real_fc;

    data.data;
    data_array_e = data.data.data_array_e;
    data_array_r = data.data.data_array_r;
    
    freq = data_array_r{1}.freq; % il y a beaucoup de copie de freq temps pis
    %indice pour zoomer
    if bool_xlim
        index = (freq >= real_fc - df) & (freq <= real_fc + df);
    else
        index =1:length(freq);
    end
    
    
    output.freq = freq(index);
    %Nf = length(freq);
    
    % construction du array de vg, Q et imK
    Ne = length(data_array_e);
    Nr = length(data_array_r);
    vg_array = cell(1,Ne+Nr);
    Q_factor = cell(1,Ne+Nr);
    imK = cell(1,Ne+Nr);
    %reK = cell(1,Ne+Nr);
    for i=1:Ne
        data_i = data_array_e{i};
        vg_array{i} = data_i.vg;
        Q_factor{i} = data_i.Q_factor;
        imK{i}      = data_i.imK;
    end
    % deuxieme boucle
    for j=1:Nr
        data_i = data_array_r{j};
        vg_array{Ne+j} = data_i.vg;
        Q_factor{Ne+j} = data_i.Q_factor;
        imK{Ne+j}      = data_i.imK;
    end
    
    %% Recuperation des infos par temps de vol 
    % real_fc = data.real_fc; % Vrai frequence centrale celle mesurée grace a la fft qu'importe la commande
    temps2vol = data.temps2vol;

    output.real_fc = real_fc;
    output.temps2vol =temps2vol; % on recopie le temps de vol

    vg_matrice = my_cell2array(vg_array); %array de taille Ne+Nr * Nf
    vg_mean = mean(vg_matrice,1);
    vg_std  = std(vg_matrice,1);
    % im(k)
    imk_matrix= my_cell2array(imK);
    imk_mean  = mean(imk_matrix,1);
    imk_std  = std(imk_matrix,1);
    % Q factor
    Q_matrix =my_cell2array(Q_factor);
    Q_mean   = mean(Q_matrix,1);
    Q_std   = std(Q_matrix,1);

    output.vg_matrice = vg_matrice(index);
    output.vg_mean    = vg_mean(index);
    output.vg_std     = vg_std(index);
    
    output.imk_matrix = imk_matrix(index);
    output.imk_mean   = imk_mean(index);
    output.imk_std    = imk_std(index);
    
    output.Q_matrix   = Q_matrix(index);
    output.Q_mean     = Q_mean(index);
    output.Q_std      = Q_std(index);
end

