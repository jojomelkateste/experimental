function [Axes_1,Axes_2] = plot_post_traitement(file_name,options)
    %PLOT_POST_TRAITEMENT Affiche deux graphs le premier c est toute les mesures avec toute les
    % paires de pulses, le second c est la meme chose avec std et moyenne
    %   Detailed explanation goes here
    arguments
        file_name 
        options.bool_xlim = true; % pour limiter en fréquences dans l affichage
        options.delta_f_affichage = 0.15e6;
        options.Visible = 'on'
        options.titre = "titre"
    end
    delta_f_affichage = options.delta_f_affichage ;
    bool_xlim = options.bool_xlim;
    titre = options.titre;
    Visible = options.Visible;% on ou off pour avoir ou pas la figure
    % load des data prétraité  
    data = load(file_name);
    data = data.data2save;
    
    data.data;
    data_array_e = data.data.data_array_e;
    data_array_r = data.data.data_array_r;
    
    freq = data_array_r{1}.freq; % il y a beaucoup de copie de freq temps pis
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
    real_fc = data.real_fc; % Vrai frequence centrale celle mesurée grace a la fft qu'importe la commande
    temps2vol = data.temps2vol;
    
    vg_temp2vol = temps2vol.vg_temp2vol;
    err_vg      = temps2vol.err_vg;
    
    ki_r = temps2vol.ki_r;
    ki_err = temps2vol.ki_err;
    
    Q = temps2vol.Q;
    Q_err = temps2vol.Q_err;
    
    
    %% Plot Brutes
    % vitesse de groupe
    figure(Visible=Visible);
    Axes_1.s1 = subplot(2,1,1);
    hold on;
    for i=1:Ne+Nr
        plot(freq,vg_array{i})
    end
    errorbar(real_fc, vg_temp2vol, err_vg, err_vg, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2,Color="black");
    if bool_xlim
        xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    end
    title("Vitesse")
    
    %  Im(k)
    Axes_1.s2 = subplot(2,2,3);
    hold on;
    for i=1:Ne+Nr
        plot(freq,imK{i})
    end
    if bool_xlim
        xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    end
    errorbar(real_fc, ki_r, ki_err, ki_err, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2,Color="black");
    title("Im(k)")
    
    Axes_1.s3 =subplot(2,2,4);
    hold on;
    for i=1:Ne+Nr
        plot(freq,Q_factor{i})
    end
    if bool_xlim
        xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    end
    errorbar(real_fc, Q, Q_err, Q_err, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2,Color="black");
    title("Facteur de qualité Q")
    sgtitle(titre)
    
    %% Affichage moyenne ecart type
    
    % Stats
    % vitesse de groupe
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
    
    LineWidth = 5;
    FontSize  = 24;
    
    figure(Visible=Visible);
    % plot de la vitesse
    Axes_2.s1 = subplot(2,1,1);
    hold on;
    plot(freq,vg_mean,LineWidth=LineWidth)
    plot(freq,vg_mean+vg_std,"r--",LineWidth=LineWidth/2)
    plot(freq,vg_mean-vg_std,"r--",LineWidth=LineWidth/2)
    fill([freq fliplr(freq)], [vg_mean-vg_std, fliplr(vg_mean+vg_std)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    % par temps de vol
    errorbar(real_fc, vg_temp2vol, err_vg, err_vg, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',25, ...
        'LineWidth',LineWidth/2,Color="black");
    if bool_xlim
        xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    end
    
    % plot de im(k)
    Axes_2.s2 = subplot(2,2,3);
    hold on;
    plot(freq,imk_mean,LineWidth=LineWidth)
    plot(freq,imk_mean+imk_std,"r--",LineWidth=LineWidth/2)
    plot(freq,imk_mean-imk_std,"r--",LineWidth=LineWidth/2)
    fill([freq fliplr(freq)], [imk_mean-imk_std, fliplr(imk_mean+imk_std)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    errorbar(real_fc, ki_r, ki_err, ki_err, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',25, ...
        'LineWidth',LineWidth/2,Color="black");
    if bool_xlim
        xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    end
    title("im(k)")
    
    Axes_2.s3 = subplot(2,2,4);
    hold on;
    plot(freq,Q_mean,LineWidth=LineWidth)
    plot(freq,Q_mean+Q_std,"r--",LineWidth=LineWidth/2)
    plot(freq,Q_mean-Q_std,"r--",LineWidth=LineWidth/2)
    fill([freq fliplr(freq)], [Q_mean-Q_std, fliplr(Q_mean+Q_std)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    errorbar(real_fc, Q, Q_err, Q_err, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',25, ...
        'LineWidth',LineWidth/2,Color="black");
    if bool_xlim
        xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    end
    title("Q factor")
    sgtitle(titre)
    
end

