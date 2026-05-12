function [pks, locs] = findpeaks_maison(signal, varargin)
    % Initialisation des paramètres par défaut
    minHeight = -inf;
    minDist = 1;

    % Lecture simplifiée des arguments (varargin)
    for i = 1:2:length(varargin)
        if strcmpi(varargin{i}, 'MinPeakHeight')
            minHeight = varargin{i+1};
        elseif strcmpi(varargin{i}, 'MinPeakDistance')
            minDist = varargin{i+1};
        end
    end

    % 1. Trouver tous les maxima locaux (plus grands que leurs voisins)
    % On utilise le décalage pour comparer x[n] avec x[n-1] et x[n+1]
    n = length(signal);
    if n < 3
        pks = []; locs = []; return;
    end
    
    % Un point est un pic si : x(i) > x(i-1) ET x(i) >= x(i+1)
    % (Le >= gère les débuts de plateaux)
    idx = find(signal(2:end-1) > signal(1:end-2) & signal(2:end-1) >= signal(3:end)) + 1;

    if isempty(idx)
        pks = []; locs = []; return;
    end

    % 2. Filtre 'MinPeakHeight'
    pks_temp = signal(idx);
    keep_h = pks_temp >= minHeight;
    idx = idx(keep_h);
    pks_temp = pks_temp(keep_h);

    % 3. Filtre 'MinPeakDistance'
    if minDist > 1 && ~isempty(idx)
        % On trie les pics par amplitude (priorité aux plus grands)
        [sorted_pks, sort_idx] = sort(pks_temp, 'descend');
        sorted_locs = idx(sort_idx);
        
        keep_dist = true(size(sorted_pks));
        
        for i = 1:length(sorted_pks)
            if keep_dist(i)
                % Supprimer tous les pics trop proches du pic actuel 'i'
                proches = abs(sorted_locs - sorted_locs(i)) < minDist;
                % On garde le pic actuel mais on invalide les autres proches
                keep_dist(proches) = false;
                keep_dist(i) = true;
            end
        end
        
        % Récupérer les pics restants et les remettre dans l'ordre chronologique
        idx = sorted_locs(keep_dist);
        idx = sort(idx); % Remettre dans l'ordre temporel
        pks_temp = signal(idx);
    end

    pks = pks_temp;
    locs = idx;
end