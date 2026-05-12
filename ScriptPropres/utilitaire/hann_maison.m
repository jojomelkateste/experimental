function w = hann_maison(L, sidetype)
    % HANN_MAISON Génère une fenêtre de Hann.
    % L : Longueur de la fenêtre
    % sidetype : 'symmetric' (défaut) ou 'periodic'

    % Gestion de l'argument par défaut
    if nargin < 2
        sidetype = 'symmetric';
    end

    % Vérification pour éviter les erreurs de division par zéro
    if L == 1
        w = 1;
        return;
    end

    % Calcul selon le type
    switch sidetype
        case 'symmetric'
            % Pour la conception de filtres (le premier et dernier point sont à 0)
            N = L - 1;
        case 'periodic'
            % Pour l'analyse spectrale / FFT
            N = L;
        otherwise
            error('Le type doit être "symmetric" ou "periodic".');
    end

    % Création de l'indice n (de 0 à L-1)
    n = (0:L-1)';

    % Application de la formule : 0.5 * (1 - cos(2*pi*n/N))
    w = 0.5 * (1 - cos(2 * pi * n / N));
end