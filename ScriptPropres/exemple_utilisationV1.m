plot_pulses=false;
plot_res = true;
%data2save contient les datas à sauvegarder 
e=2e-2;

addpath("C:\Users\melka\Desktop\experimental_reprise\fonctions") % ordi portable
addpath(genpath("C:\Users\Utilisateur\Desktop\Experimental\ScriptPropres")) % ordi fixe
%namebase = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\transverse\";
namebase = "C:\Users\Utilisateur\Desktop\Experimental\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\transverse\";
name_c1 = namebase+"transverse_fc_0p5Mhz_c1.mat";%0.5 ok
name_c2 = namebase+"transverse_fc_0p5Mhz_c2.mat";
fc = 0.5e6;

data2save.metadata.name_c1 = name_c1;
data2save.metadata.name_c2 = name_c2;
data2save.metadata.name_fc = fc;

% parametre pour détecter les pics on commence haut puis on affinera
disp("Décommenter ici pour pics grossier")
% MinPeakDistance =  -1; % pas de distence minimum pour commencer
% MinPeakHeight1  = 4e-3;
% MinPeakHeight2  = 4e-3;


% On affine pour trouver les pics
%disp("Décommenter ici pour affiner ")
MinPeakDistance =  1000; % pas en indices pour la distence minimum pour comencer
MinPeakHeight1  = 2e-3;
MinPeakHeight2  = 1.5e-3;

nb_sat_e = 1; % nombre de pics emeteur saturés dans le calibre 1
nb_sat_r = 1; % nombre de pics recepteur saturés dans le calibre 1
% Utile pour les pulses saturés et pas saturés

[output] = files2struct_2calibres(name_c1,name_c2,nb_sat_e,nb_sat_r,MinPeakDistance,MinPeakHeight1,MinPeakHeight2);


%% le temps de vol
pic_struct = output.pics.pic_concat;
[vs_e,ki_e,ki_err_e] = pic2temp2vol(pic_struct.pic_e(2:end),pic_struct.pic_e_index(2:end),output.temps,e);
[vs_r,ki_r,ki_err_r] = pic2temp2vol(pic_struct.pic_r,pic_struct.pic_r_index,output.temps,e);
ki_err = ki_err_r.normr*ki_r; %erreur sur ki
%ki_err = mean( ki_err_r.normr*ki_r + ki_err_e.normr*ki_e); l emeteur a
%moins de pic ca entache la moyenne
vs_temp2vol = mean([vs_e,vs_r]);
err_vs = std([vs_e,vs_r]);
Q = 2*pi*fc/2/vs_temp2vol/ki_r;
Q_err = sqrt((err_vs/vs_temp2vol)^2+(ki_err_r.normr)^2) * Q;

data2save.temps2vol.vs_temp2vol = vs_temp2vol;
data2save.temps2vol.err_vs = err_vs;
data2save.temps2vol.ki_r = ki_r;
data2save.temps2vol.ki_err = ki_err;
data2save.temps2vol.Q = Q;
data2save.temps2vol.Q_err = Q_err;
%%

% S = output.emeteur.c1;
% pic_indexes = output.pics.emeteur.c1.pic_id;
% [pulse_array] = fenetre_rect(S,pic_indexes,false);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Recuperation des pulses %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% le pulse d emission est juste ignoré
[pulse_e,pulse_r] = data_and_window2pulses(output,"rect",nb_sat_e,nb_sat_r, plot_pulses);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Traitement du signal %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% option.tronq   =  false ;% pour tronquer les frequence
% option.fc      = 1e6    ;    % fc a donner pour les option de troncature
% option.delta_f = 0.1e6  ; 
[data] = pulses2data(output.freq,pulse_e{2},pulse_e{3},e, ...
    "tronq",true,"delta_f",0.1e6,"fc",fc);

figure("Name","Un seul plot pour tester");
subplot(1,3,1)
plot(data.freq,data.vg)
hold on
errorbar(fc, vs_temp2vol, err_vs, err_vs, 0, 0, ...
    'LineStyle','none', ...
    'Marker','+', ...
    'MarkerSize',12, ...
    'LineWidth',2);
title("Une vitesse de groupe")

subplot(1,3,2)
plot(data.freq,data.imK)
title("Une IM(k)")


subplot(1,3,3)
plot(data.freq,data.Q_factor)
title("Un  facteur de qualité")

%% champ avec l emeteur
[data_array_e] = map_pulses2data(output.freq,pulse_e,e, ...
    "tronq",true,"delta_f",0.1e6,"fc",fc);
%champ avec le recepteur
[data_array_r] = map_pulses2data(output.freq,pulse_r,e, ...
    "tronq",true,"delta_f",0.1e6,"fc",fc);

data2save.data.data_array_e =  data_array_e;
data2save.data.data_array_r =  data_array_r;

%% figure vitesses 
if plot_res
    figure;
    subplot(1,3,1)
    hold on;
    for data_cell= data_array_e
        data = data_cell{1};
        plot(data.freq,data.vg)
    end
    errorbar(fc, vs_temp2vol, err_vs, err_vs, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2);
    title("Juste avec l'emeteur")
    
    subplot(1,3,2)
    hold on;
    for data_cell= data_array_r
        data = data_cell{1};
        plot(data.freq,data.vg)
    end
    errorbar(fc, vs_temp2vol, err_vs, err_vs, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2);
    title("Juste avec le recepteur")
    
    subplot(1,3,3)
    hold on;
    for data_cell= data_array_e
        data = data_cell{1};
        plot(data.freq,data.vg)
    end
    for data_cell= data_array_r
        data = data_cell{1};
        plot(data.freq,data.vg)
    end
    errorbar(fc, vs_temp2vol, err_vs, err_vs, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2);
    title("tout les plots")
    
    sgtitle("vitesse de groupe")
    
    %% figure imk 
    figure;
    subplot(1,3,1)
    hold on;
    for data_cell= data_array_e
        data = data_cell{1};
        plot(data.freq,data.imK)
    end
    title("Juste avec l'emeteur")
    
    subplot(1,3,2)
    hold on;
    for data_cell= data_array_r
        data = data_cell{1};
        plot(data.freq,data.imK)
    end
    title("Juste avec le recepteur")
    
    subplot(1,3,3)
    hold on;
    for data_cell= data_array_e
        data = data_cell{1};
        plot(data.freq,data.imK)
    end
    for data_cell= data_array_r
        data = data_cell{1};
        plot(data.freq,data.imK)
    end
    errorbar(fc, ki_r, ki_err, ki_err, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2);
    title("tout les plots")
    
    sgtitle("imK")
    
    %% figure Q_factor 
    figure;
    subplot(1,3,1)
    hold on;
    for data_cell= data_array_e
        data = data_cell{1};
        plot(data.freq,data.Q_factor)
    end
    title("Juste avec l'emeteur")
    
    subplot(1,3,2)
    hold on;
    for data_cell= data_array_r
        data = data_cell{1};
        plot(data.freq,data.Q_factor)
    end
    title("Juste avec le recepteur")
    
    subplot(1,3,3)
    hold on;
    for data_cell= data_array_e
        data = data_cell{1};
        plot(data.freq,data.Q_factor)
    end
    for data_cell= data_array_r
        data = data_cell{1};
        plot(data.freq,data.Q_factor)
    end
    errorbar(fc, Q, Q_err, Q_err, 0, 0, ...
        'LineStyle','none', ...
        'Marker','+', ...
        'MarkerSize',12, ...
        'LineWidth',2,Color="blue");
    
    title("tout les plots")
    
    sgtitle("Q factor")
end


%% 
% 1. Calcul de la taille en Mégaoctets (Mo)
info_var = whos('data2save');
taille_octets = info_var.bytes;
taille_mo = taille_octets / 1024^2; % 1 Mo = 1024 * 1024 octets

% 2. Préparation du message
message = sprintf('Voulez-vous sauvegarder la variable "data2save" ?\n\nOccupation mémoire : %.2f Mo', taille_mo);

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
        uisave('data2save', 'processed_data_fc_.mat'); 
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
