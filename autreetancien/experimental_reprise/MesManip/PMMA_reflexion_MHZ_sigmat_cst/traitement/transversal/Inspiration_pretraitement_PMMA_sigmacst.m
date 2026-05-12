% Load du fichier
addpath('C:\Users\melka\Desktop\experimental_reprise\fonctions')
name1 = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\longitudinal\";
name1 = name1+"longi_fc_0p9.mat";
fc = 0.9e6;
e = 0.02;

% A modifier si on a pas tout les pics
MinPeakHeight = 0.06;% defaut 0.05
MinPeakDistance = 200;%defaut 200 

S = load(name1);
src1 = S.src1; % emeteur
src2 = S.src2; % recepteur 


% On fait le traitement
[data_traite] = traitement_automatique(S.src2,e,fc,MinPeakHeight,MinPeakDistance); 

% On demande si on veut sauvegarder les infos
%%
% 1. Calcul de la taille en Mégaoctets (Mo)
info_var = whos('data_traite');
taille_octets = info_var.bytes;
taille_mo = taille_octets / 1024^2; % 1 Mo = 1024 * 1024 octets

% 2. Préparation du message
message = sprintf('Voulez-vous sauvegarder la variable "data_traite" ?\n\nOccupation mémoire : %.2f Mo', taille_mo);

% 3. Affichage de la boîte de dialogue (Oui / Non)
reponse = questdlg(message, ...
    'Sauvegarde des données', ...  % Titre de la fenêtre
    'Oui', 'Non', ...              % Boutons disponibles
    'Oui');                        % Bouton par défaut

% 4. Traitement de la réponse
switch reponse
    case 'Oui'
        % Option A : Ouvrir une fenêtre pour choisir le nom et le dossier
        % C'est le plus sûr pour ne pas écraser de fichiers par erreur.
        name = "processed_data_fc_.mat";
        uisave('data_traite', 'processed_data_fc_.mat'); 
        disp('*** Procédure de sauvegarde lancée. ***');
        
        % Option B (Alternative) : Sauvegarde automatique directe sans demander le nom
        % save('resultats_auto.mat', 'data_traite');
        % disp('*** Données sauvegardées dans resultats_auto.mat ***');
        
    case 'Non'
        disp('*** Sauvegarde annulée par l''utilisateur. ***');
        
    otherwise
        % Cas où l'utilisateur ferme la fenêtre avec la croix
        disp('*** Fenêtre fermée. Aucune sauvegarde effectuée. ***');
end

%%
% On fait les plot qu on veut voir

%% plot du temps de vol

% J avais oublie voici des definitions a verifier 
N_courbes = length(data_traite.vg_array);
N_points = length(data_traite.vg_array{1});
freq = data_traite.freq_bis(1:end-1);

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