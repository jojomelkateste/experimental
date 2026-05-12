function renommer_fichiers()
    % --- Paramètres de renommage ---
    
    % Nouveau préfixe souhaité
    nouveau_prefixe = 'longi_';
    
    % Génération automatique des anciens préfixes (de 'essai_1_' à 'essai_11_')
    num_debut = 1;
    num_fin = 11;
    anciens_prefixes_a_traiter = cell(1, num_fin - num_debut + 1);
    
    for i = num_debut:num_fin
        anciens_prefixes_a_traiter{i} = ['essai_', num2str(i), '_'];
    end
    
    % --- Exécution du renommage ---
    
    % On cherche tous les fichiers commençant par 'essai_'
    motif_recherche = 'essai_*';
    
    % 1. Lister tous les fichiers correspondant au motif 'essai_*'
    fichiers = dir(motif_recherche);
    fichiers = fichiers(~[fichiers.isdir]); 

    if isempty(fichiers)
        disp(['Aucun fichier trouvé avec le motif : ', motif_recherche]);
        return; 
    end

    disp(['Début du renommage pour ', num2str(length(fichiers)), ' fichiers...']);
    fichiers_renommes_compteur = 0;

    % 2. Parcourir et renommer chaque fichier
    for i = 1:length(fichiers)
        ancien_nom = fichiers(i).name;
        nouveau_nom = ancien_nom; 
        renomme_effectue = false;
        
        % Tenter de remplacer l'un des anciens préfixes générés
        for j = 1:length(anciens_prefixes_a_traiter)
            ancien_prefixe = anciens_prefixes_a_traiter{j};
            
            % Vérifier si le nom de fichier commence par cet ancien préfixe
            if startsWith(ancien_nom, ancien_prefixe)
                % Remplacer l'ancien préfixe par le nouveau
                nouveau_nom = strrep(ancien_nom, ancien_prefixe, nouveau_prefixe);
                renomme_effectue = true;
                break; % Arrêter la recherche de préfixe pour ce fichier
            end
        end
        
        % 3. Exécuter l'opération de renommage
        if renomme_effectue
            if ~strcmp(ancien_nom, nouveau_nom) 
                [status, message, messageId] = movefile(ancien_nom, nouveau_nom);
                
                if status == 1
                    disp(['Renommé : ', ancien_nom, ' -> ', nouveau_nom]);
                    fichiers_renommes_compteur = fichiers_renommes_compteur + 1;
                else
                    warning(['Échec du renommage de ', ancien_nom, '. Message : ', message]);
                end
            end
        else
            % Ceci s'affiche si un fichier commence par 'essai_' mais n'est pas suivi 
            % d'un numéro de 1 à 11 (ex: 'essai_final.txt').
            disp(['Ignoré (pas de préfixe essai_1_ à essai_11_ reconnu) : ', ancien_nom]);
        end
    end

    disp(' ');
    disp(['*** Renommage terminé. ', num2str(fichiers_renommes_compteur), ' fichiers renommés. ***']);
end