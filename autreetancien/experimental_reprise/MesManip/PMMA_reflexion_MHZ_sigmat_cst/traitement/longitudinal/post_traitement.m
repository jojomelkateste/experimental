LineWidth = 5;
FontSize  = 24;

%name_base = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\traitement\longitudinal\";
name_base = "C:\Users\Utilisateur\Desktop\Experimental\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\traitement\longitudinal\";


name_base = name_base+"processed_data_fc_";

name_end = ["0p5","0p6","0p7","0p8","0p9","1p0","1p1","1p2","1p3","1p4","1p5"];

freq = [];
% vitesse de groupe
vg_array = []; 
min_vg_array = [];
max_vg_array = [];
% partie imaginaire de k
imK_array = [];
min_imK_array = [];
max_imK_array = [];
% facteur de qualité Q
Q_array = [];
min_Q_array = [];
max_Q_array = [];
temps2vol = [];
for ne = name_end
    % On ouvre les data
    name = name_base+ne+".mat";
    S = load(name);
    data_traite = S.data_traite;
    % On recuperer le min le max
    N_courbes = length(data_traite.vg_array);
    N_points = length(data_traite.vg_array{1});
    % vitesse de groupe
    moyenne_vg = zeros(1,N_points);
    min_vg     = zeros(1,N_points)+Inf;
    max_vg     = zeros(1,N_points);
    % partie imaginaire de k
    moyenne_imK = zeros(1,N_points);
    min_imK = zeros(1,N_points)+Inf;
    max_imK = zeros(1,N_points);
    % facteur de qualité Q
    moyenne_Q = zeros(1,N_points);
    min_Q = zeros(1,N_points)+Inf;
    max_Q = zeros(1,N_points);
    for i=1:N_courbes
        %vitesse de groupe
        data_vector = data_traite.vg_array{i};
        moyenne_vg = moyenne_vg + data_vector; % Accumulation de la somme
        min_vg   = min(min_vg, data_vector);  % Met à jour le minimum global point par point
        max_vg   = max(max_vg, data_vector);  % Met à jou
        % Partie imaginaire de imK
        data_vector = data_traite.imK_array{i};
        data_vector = data_vector(1:end-1);
        moyenne_imK = moyenne_imK +data_vector;
        min_imK = min(min_imK, data_vector);
        max_imK = max(max_imK, data_vector);
        % facteur de qualité Q
        data_vector = data_traite.Q_array{i};
        data_vector = data_vector(1:end-1);
        moyenne_Q = moyenne_Q + data_vector;
        min_Q = min(min_Q, data_vector);
        max_Q = max(max_Q, data_vector);
    end
    moyenne_vg = moyenne_vg/N_courbes;
    moyenne_imK = moyenne_imK/N_courbes;
    moyenne_Q = moyenne_Q/N_courbes;

    % on rempli les arrays
    freq = [freq,data_traite.freq_bis(1:end-1)];
    % vitesse de groupe
    vg_array = [vg_array,moyenne_vg];
    min_vg_array = [min_vg_array,min_vg];
    max_vg_array = [max_vg_array,max_vg];  % CORRECTION: max_vg au lieu de min_vg
    % imK
    imK_array = [imK_array,moyenne_imK];
    min_imK_array = [min_imK_array,min_imK];
    max_imK_array = [max_imK_array,max_imK];
    % Q
    Q_array = [Q_array,moyenne_Q];
    min_Q_array = [min_Q_array,min_Q];
    max_Q_array = [max_Q_array,max_Q];
    temps2vol = [temps2vol,mean(data_traite.temps2vol)];
end

% Tri des données par fréquence croissante
[freq, idx_sort] = sort(freq);
% vg
vg_array = vg_array(idx_sort);
min_vg_array = min_vg_array(idx_sort);
max_vg_array = max_vg_array(idx_sort);
% imK
imK_array = imK_array(idx_sort);
min_imK_array = min_imK_array(idx_sort);
max_imK_array = max_imK_array(idx_sort);
% Q
Q_array = Q_array(idx_sort);
min_Q_array = min_Q_array(idx_sort);
max_Q_array = max_Q_array(idx_sort);

% Gestion des doublons de fréquence en moyennant les valeurs
[freq_unique, ~, idx_unique] = unique(freq);
% vg
vg_moyenne = zeros(size(freq_unique));
min_vg_moyenne = zeros(size(freq_unique));
max_vg_moyenne = zeros(size(freq_unique));
% imK
imK_moyenne = zeros(size(freq_unique));
min_imK_moyenne = zeros(size(freq_unique));
max_imK_moyenne = zeros(size(freq_unique));
% Q
Q_moyenne = zeros(size(freq_unique));
min_Q_moyenne = zeros(size(freq_unique));
max_Q_moyenne = zeros(size(freq_unique));

for i = 1:length(freq_unique)
    indices = (idx_unique == i);  % Trouve tous les indices avec cette fréquence
    % vg
    vg_moyenne(i) = mean(vg_array(indices));
    min_vg_moyenne(i) = min(min_vg_array(indices));  % Prend le min des mins
    max_vg_moyenne(i) = max(max_vg_array(indices));  % Prend le max des maxs
    % imK
    imK_moyenne(i) = mean(imK_array(indices));
    min_imK_moyenne(i) = min(min_imK_array(indices));
    max_imK_moyenne(i) = max(max_imK_array(indices));
    % Q
    Q_moyenne(i) = mean(Q_array(indices));
    min_Q_moyenne(i) = min(min_Q_array(indices));
    max_Q_moyenne(i) = max(max_Q_array(indices));
end

% Remplace les arrays par les versions sans doublons
freq = freq_unique;
vg_array = vg_moyenne;
min_vg_array = min_vg_moyenne;
max_vg_array = max_vg_moyenne;
imK_array = imK_moyenne;
min_imK_array = min_imK_moyenne;
max_imK_array = max_imK_moyenne;
Q_array = Q_moyenne;
min_Q_array = min_Q_moyenne;
max_Q_array = max_Q_moyenne;
%%

f = figure;
hold on;
title('Moyenne des courbes avec écart Min/Max',FontSize=FontSize*2);
xlabel('f [Hz]',FontSize=FontSize);
ylabel('Valeur S',FontSize=FontSize);
% 1. Trace la ligne de la moyenne
h_mean = plot(freq, vg_array, 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Moyenne S(x)',LineWidth=LineWidth);
% 
plot(freq,min_vg_array,"r--",'DisplayName', 'minimum',LineWidth=LineWidth/2)
plot(freq,max_vg_array,"r--",'DisplayName', 'maximum',LineWidth=LineWidth/2)
fill([freq fliplr(freq)], [min_vg_array fliplr(max_vg_array)], ...
     'b', 'FaceAlpha',0.2, 'EdgeColor','none');
ax = gca;          % Récupère l'axe courant
ax.FontSize = FontSize;  % Change la taille des ticks
% insere ici le temps de vol moyen en escalier
%yyaxis right;
% Les intervalles sont: 0.4-0.6, 0.5-0.7, 0.6-0.8, ..., 1.4-1.6 MHz
% freq_edges = [0.4, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6] * 1e6;
% temps2vol_stairs = [temps2vol(1), temps2vol(1:end)]; % Répète la première valeur pour l'escalier
% stairs(freq_edges, temps2vol_stairs, 'LineWidth', 2, 'Color', 'm', 'DisplayName', 'Temps de vol moyen');
fc_values = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5] * 1e6;
scatter(fc_values, temps2vol, 200, "+" ,'DisplayName', 'Par temps de vol moyen', 'LineWidth', 3,'MarkerEdgeColor',"K")
ylabel('Vitesse en m/s');
%yyaxis left;
lg = legend();
%lg.ItemTokenSize = [20 50];
hold off;
saveas(f,"v_p_PMM_scst.fig")
%% Figure 2: imK avec kpp
f = figure;
hold on;
title('Partie imaginaire de k avec écart Min/Max',FontSize=FontSize*2);
xlabel('f [Hz]',FontSize=FontSize);
ylabel('Im(k)',FontSize=FontSize);
% Trace la ligne de la moyenne
plot(freq, imK_array, 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Moyenne Im(k)',LineWidth=LineWidth);
% 
plot(freq, min_imK_array, "r--", 'DisplayName', 'minimum',LineWidth=LineWidth/2)
plot(freq, max_imK_array, "r--", 'DisplayName', 'maximum',LineWidth=LineWidth/2)
fill([freq fliplr(freq)], [min_imK_array fliplr(max_imK_array)], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
ax = gca;          % Récupère l'axe courant
ax.FontSize = FontSize;  % Change la taille des ticks
% Récupération de kpp pour chaque fichier
kpp_values = [];
for ne = name_end
    name = name_base + ne + ".mat";
    S = load(name);
    data_traite = S.data_traite;
    kpp_values = [kpp_values, data_traite.kpp];
end

% Plot des kpp en scatter
fc_values = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5] * 1e6;
scatter(fc_values, kpp_values, 200, "+", 'DisplayName', 'kpp', 'LineWidth', 3,'MarkerEdgeColor',"K")
legend();

hold off;
saveas(f,"imK_PMM_scst.fig")
%% Figure 3: Q
f = figure;
hold on;
title('Facteur de qualité Q avec écart Min/Max',FontSize=FontSize*2);
xlabel('f [Hz]',FontSize=FontSize);
ylabel('Q',FontSize=FontSize);
% Trace la ligne de la moyenne
plot(freq, Q_array, 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Moyenne Q',LineWidth=LineWidth);
% 
plot(freq, min_Q_array, "r--", 'DisplayName', 'minimum',LineWidth=LineWidth)
plot(freq, max_Q_array, "r--", 'DisplayName', 'maximum',LineWidth=LineWidth)
fill([freq fliplr(freq)], [min_Q_array fliplr(max_Q_array)], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
legend();
ax = gca;          % Récupère l'axe courant
ax.FontSize = FontSize;  % Change la taille des ticks
hold off;

saveas(f,"Q_factor_PMM_scst.fig")
%% Plot du temps de vol
% f = figure;
% hold on;
% title('Temps de vol en fonction de la fréquence centrale');
% xlabel('Fréquence centrale (Hz)');
% ylabel('Temps de vol (s)');
% fc_values = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5] * 1e6;
% plot(fc_values, temps2vol, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Temps de vol moyen');
% grid on;
% legend();
% hold off;