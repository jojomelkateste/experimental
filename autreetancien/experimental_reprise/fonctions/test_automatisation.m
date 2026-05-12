
set(0,'DefaultFigureColor','white');
set(0,'DefaultAxesColor','white');
set(0,'DefaultAxesXColor','black');
set(0,'DefaultAxesYColor','black');
set(0,'DefaultTextColor','black');


test1 = false;
test2 = true;

if test1
    % Load de donnée test;
    data_dir = "C:\Users\melka\Desktop\experimental_reprise\MesManip\Epoxy_MegaHz";
    name1 = data_dir+"\Epoxy_l49mm_1Mhz.mat";
    load(name1);
    uz_e = src1.Data; % emmetteur
    uz_r = src2.Data; % recepteur
    fe = src1.SampleFrequency; %frequence d'echentillonage
    N = length(uz_e);
    temps = (0:(N-1))/fe; % temps 
    freq = (-N/2:N/2-1)*(fe/N);
    
    % test de remove_noise
    eps = 0.001;
    %[uz_r_clean] = remove_noise(uz_r,eps);
    %uz_r_clean = lowpass(uz_r,1.5e6,fe);
    [uz_r_clean] = remove_noise(uz_r,freq,fe);
    [uz_e_clean] = remove_noise(uz_e,freq,fe);
    
    figure;
    hold on;
    plot(uz_r_clean);
    plot(uz_r,'r--');
    hold off;
    
    figure;
    hold on;
    plot(uz_e_clean);
    plot(uz_e,'r--');
    hold off;
    
    %% test de pulse_detection
    
    [pic,pic_times,pulse_array] = pulse_detection(temps,uz_r_clean);
    % [pic_e,pic_times_e,pulse_array_e] = pulse_detection(temps,uz_e_clean);
    % % test du temps de vol 
    % %%
    e = 0.049;
    d = 2*e;
    % v_array = temps_vol(pic_times_e,pic_times,e);
    % % [v_array] = temps_vol(pic_times,2*e);
    % disp(v_array);
    %% on regarde pour le facteur de qualité
    fc = 1e6;
    [vg,outputArg2] = spectrale_analysis(pulse_array{2},pulse_array{3},freq,fc,d);
    % pulse1 = pulse_array{2};
    % pulse2 = pulse_array{3};
    % pulse1_fft = fftshift(ifft(pulse1));
    % pulse2_fft = fftshift(ifft(pulse2));
    % % Il peut il y avoir trop de point 
    % figure;
    % plot(abs(pulse1_fft))
end
%%
if test2
    disp("Deuxieme teste traitement automatique")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    name1 = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_transmmission_MHZ\longitudinal\";
    name1 = name1+"20251128_essai001.mat";
    S = load(name1);
    e = 0.02;
    [data_traite] = traitement_automatique(S.src2,e,fc);
    %% recuperation des infos utiles 
    freq  = data_traite.freq_bis(2:end);
    N_points = length(freq); % Nombre de points X
    N_courbes = length(data_traite.vg_array);
    %% plot du temps de vol
    figure;
    plot(data_traite.temps2vol )
    xlabel("Index")
    % plot de la vitesse de groupes
    figure;
    hold on;
    moyenne_vg = zeros(1,N_points);
    min_vg     = zeros(1,N_points)+Inf;
    max_vg     = zeros(1,N_points);
    for i=1:N_courbes
        name = "Pulse "+num2str(i)+" et "+num2str(i+1) ;
        data_vector = data_traite.vg_array{i};
        plot(freq,data_vector,DisplayName=name)
        %
        moyenne_vg = moyenne_vg + data_vector; % Accumulation de la somme
        min_vg   = min(min_vg, data_vector);  % Met à jour le minimum global point par point
        max_vg   = max(max_vg, data_vector);  % Met à jou
    end
    moyenne_vg = moyenne_vg/N_courbes;
    legend()
    hold off
    %%
    figure;
    hold on;
    title('Moyenne des courbes avec écart Min/Max');
    xlabel('Fréquence X');
    ylabel('Valeur S');
    % 1. Trace la ligne de la moyenne
    h_mean = plot(freq, moyenne_vg, 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Moyenne S(x)');
    % 
    plot(freq,min_vg,"r--")
    plot(freq,max_vg,"r--")
    fill([freq fliplr(freq)], [min_vg fliplr(max_vg)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');

    hold off;
    % % 2. Ajoute la zone d'erreur Min/Max (patch)
    % fill([freq; flipud(freq)], [min_vg; flipud(max_vg)], [0.8 0.8 1], ... % Couleur bleu clair [0.8 0.8 1]
    %     'EdgeColor', 'none', ...
    %     'DisplayName', 'Min/Max Range', ...
    %     'FaceAlpha', 0.5); % Transparence
end