function verification_fc_fichier_wave()
    % Définition des paramètres
    fc_min_MHz = 0.5;
    fc_max_MHz = 1.5;
    fc_step_MHz = 0.1;
    fp = 1000; 

    % --- Préparation des noms de fichiers ---
    fc_values_MHz = fc_min_MHz : fc_step_MHz : fc_max_MHz;
    fc_str_list = arrayfun(@(x) strrep(sprintf('%.2f', x), '.', 'p'), fc_values_MHz, 'UniformOutput', false);

    file_names = cell(length(fc_str_list), 1);
    for i = 1:length(fc_str_list)
        file_names{i} = "gaussien_sfst_cst_fc_" + fc_str_list{i} + "MHz_frep_" + fp + "Hz.wav";
    end

    current_index = 1;
    max_index = length(file_names);
    
    % --- Création de la figure ---
    h_fig = figure('Name', 'Visualisation FFT (Clavier/Boutons/Zoom)', 'NumberTitle', 'off');
    
    % Configuration du KeyPressFcn pour la navigation clavier
    set(h_fig, 'KeyPressFcn', @figure_key_press);
    
    % --- Ajout des Boutons UICONTROL ---
    
    % Bouton PRÉCÉDENT
    uicontrol('Style', 'pushbutton', 'String', '<< Précédent (Flèche Gauche)', ...
              'Units', 'normalized', 'Position', [0.05 0.01 0.25 0.05], ...
              'Callback', @previous_button_callback);

    % Bouton SUIVANT
    uicontrol('Style', 'pushbutton', 'String', 'Suivant >> (Flèche Droite)', ...
              'Units', 'normalized', 'Position', [0.70 0.01 0.25 0.05], ...
              'Callback', @next_button_callback);
              
    % Bouton QUITTER
    uicontrol('Style', 'pushbutton', 'String', 'Quitter (Esc)', ...
              'Units', 'normalized', 'Position', [0.375 0.01 0.25 0.05], ...
              'Callback', @quit_button_callback);
    
    % Afficher le premier graphique
    plot_current_fft();
    
    % --- Fonctions imbriquées pour la navigation ---
    
    function restore_focus()
        % Fonction cruciale : Redonne le focus à la figure pour réactiver les événements clavier.
        % Utile après avoir utilisé les outils de zoom/pan.
        uicontrol(h_fig); 
    end

    function figure_key_press(src, event)
        % Navigation par clavier
        if strcmp(event.Key, 'rightarrow') 
            next_button_callback();
        elseif strcmp(event.Key, 'leftarrow') 
            previous_button_callback();
        elseif strcmp(event.Key, 'escape')
             quit_button_callback();
        end
        % Le focus est maintenu tant qu'on n'utilise pas les outils internes de MATLAB.
    end
    
    function previous_button_callback(~, ~)
        if current_index > 1
            current_index = current_index - 1;
            plot_current_fft();
        else
            disp('Début de la liste des fichiers.');
        end
        restore_focus(); % S'assurer que le focus revient à la figure après le clic
    end

    function next_button_callback(~, ~)
        if current_index < max_index
            current_index = current_index + 1;
            plot_current_fft();
        else
            disp('Fin de la liste des fichiers.');
        end
        restore_focus(); % S'assurer que le focus revient à la figure après le clic
    end

    function quit_button_callback(~, ~)
        close(h_fig);
    end
    
    % --- Fonction d'affichage ---
    
    function plot_current_fft()
        current_file = file_names{current_index};
        
        try
            % Lecture du fichier WAV
            [A, fe] = audioread(current_file);
            if iscolumn(A), A = A'; end

            % Calcul de la FFT
            N = length(A);
            Nf = 4*N;
            ATF = fftshift(fft(A, Nf));
            Freq = ((-Nf/2 : Nf/2 - 1) * fe / Nf);
            
            % Affichage
            figure(h_fig); 
            % Utiliser la fonction gca pour obtenir l'axe courant
            h_ax = gca;
            plot(h_ax, Freq/1e6, abs(ATF)); % Afficher sur l'axe
            
            % Extraction de fc pour le titre
            fc_title_match = regexp(current_file, 'fc_(\d+p\d+)MHz', 'tokens', 'once');
            fc_title = 0;
            if ~isempty(fc_title_match)
                fc_title_str = strrep(fc_title_match{1}, 'p', '.');
                fc_title = str2double(fc_title_str);
            end

            title_str = sprintf('FFT du Signal | $f_c$ = %.2f MHz (Fichier %d/%d)', ...
                                fc_title, current_index, max_index);
            title(title_str, 'Interpreter', 'latex');
            
            xlabel('Fréquence (MHz)');
            ylabel('Magnitude de la FFT (arbitraire)');
            
            disp(['Affichage de : ', current_file]);
            
        catch ME
            warning('Fichier non trouvé ou erreur de lecture : %s\nErreur: %s', current_file, ME.message);
            if current_index < max_index
                current_index = current_index + 1;
                plot_current_fft();
            end
        end
    end
end

% function visualiser_ffts_gaussiennes()
%     % Définition des paramètres d'itération (selon votre description)
%     fc_min_MHz = 0.5;
%     fc_max_MHz = 1.5;
%     fc_step_MHz = 0.1;
% 
%     % Fréquence de répétition (fp) utilisée dans votre code de génération
%     fp = 1000; 
% 
%     % Générer la liste des fréquences centrales (en MHz)
%     fc_values_MHz = fc_min_MHz : fc_step_MHz : fc_max_MHz;
% 
%     % Convertir les fréquences pour former les noms de fichiers (ex: 1.5 -> 1p50)
%     % On utilise 'sprintf' pour formater le nombre avec deux décimales et remplacer le point par 'p'.
%     fc_str_list = arrayfun(@(x) strrep(sprintf('%.2f', x), '.', 'p'), fc_values_MHz, 'UniformOutput', false);
% 
%     % Créer la liste complète des noms de fichiers
%     file_names = cell(length(fc_str_list), 1);
%     for i = 1:length(fc_str_list)
%         % Nom de fichier basé sur votre format : gaussien_sfst_cst_fc_1p50MHz_frep_1000Hz.wav
%         file_names{i} = "gaussien_sfst_cst_fc_" + fc_str_list{i} + "MHz_frep_" + fp + "Hz.wav";
%     end
% 
%     % Initialisation de l'index et de la figure
%     current_index = 1;
%     max_index = length(file_names);
% 
%     % Création de la figure pour l'affichage interactif
%     h_fig = figure('Name', 'Visualisation FFT des Gaussiennes', 'NumberTitle', 'off');
% 
%     % Configuration de la figure pour la navigation (utilisation de 'KeyPressFcn')
%     % La fonction 'figure_key_press' sera appelée à chaque pression de touche.
%     set(h_fig, 'KeyPressFcn', @figure_key_press);
% 
%     % Afficher le premier graphique
%     plot_current_fft();
% 
%     % --- Fonctions imbriquées ---
% 
%     % Fonction pour la navigation via la pression des touches
%     function figure_key_press(src, event)
%         % Touches de navigation
%         if strcmp(event.Key, 'rightarrow') || strcmp(event.Key, 'space') || strcmp(event.Key, 'n')
%             % Touche Flèche Droite, Espace ou 'n' (pour Next)
%             if current_index < max_index
%                 current_index = current_index + 1;
%                 plot_current_fft();
%             else
%                 disp('Fin de la liste des fichiers.');
%             end
%         elseif strcmp(event.Key, 'leftarrow') || strcmp(event.Key, 'p')
%             % Touche Flèche Gauche ou 'p' (pour Previous)
%             if current_index > 1
%                 current_index = current_index - 1;
%                 plot_current_fft();
%             else
%                 disp('Début de la liste des fichiers.');
%             end
%         elseif strcmp(event.Key, 'escape')
%              % Touche Echap pour fermer
%              close(h_fig);
%         end
%     end
% 
%     % Fonction pour lire le fichier courant, calculer et afficher la FFT
%     function plot_current_fft()
%         current_file = file_names{current_index};
% 
%         try
%             % Lire le fichier WAV
%             % A: données du signal, fe: fréquence d'échantillonnage
%             [A, fe] = audioread(current_file);
% 
%             % Vérifier si A est un vecteur
%             if iscolumn(A)
%                 A = A'; % S'assurer que c'est un vecteur ligne pour le traitement FFT standard
%             end
% 
%             % Calcul de la FFT
%             N = length(A);
%             Nf = 4*N; % Utilisation du même zero-padding que dans votre code
%             ATF = fftshift(fft(A, Nf));
% 
%             % Création du vecteur de fréquence
%             Freq = ((-Nf/2 : Nf/2 - 1) * fe / Nf);
% 
%             % Affichage
%             figure(h_fig); % Activer la figure existante
%             plot(Freq/1e6, abs(ATF)); % Afficher Freq en MHz
% 
%             % Déterminer le fc à partir du nom de fichier pour le titre
%             % Regex pour extraire la partie 'XpXX' après 'fc_' et avant 'MHz'
%             fc_title_match = regexp(current_file, 'fc_(\d+p\d+)MHz', 'tokens', 'once');
% 
%             if ~isempty(fc_title_match)
%                 fc_title_str = strrep(fc_title_match{1}, 'p', '.'); % Reconvertir 'p' en '.'
%                 fc_title = str2double(fc_title_str);
%             else
%                 fc_title = NaN; % En cas d'erreur
%             end
% 
%             % Titre
%             title_str = sprintf('FFT du Signal | $f_c$ = %.2f MHz (Fichier %d/%d)', ...
%                                 fc_title, current_index, max_index);
%             title(title_str, 'Interpreter', 'latex');
% 
%             % Labels
%             xlabel('Fréquence (MHz)');
%             ylabel('Magnitude de la FFT (arbitraire)');
% 
%             % Afficher l'index dans la console pour un suivi facile
%             disp(['Affichage de : ', current_file]);
% 
%         catch ME
%             % Gestion d'erreur si le fichier n'est pas trouvé
%             warning('Fichier non trouvé ou erreur de lecture : %s\nErreur: %s', current_file, ME.message);
%             disp('Passage au fichier suivant...');
%             if current_index < max_index
%                 current_index = current_index + 1;
%                 plot_current_fft(); % Tenter le fichier suivant
%             else
%                 disp('Fin de la liste des fichiers.');
%             end
%         end
%     end
% end