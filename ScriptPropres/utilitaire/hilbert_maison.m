function z = hilbert_maison(x)
    % On s'assure que x est un vecteur colonne
    x = x(:);
    n_orig = length(x);
    
    % 1. On rajoute des zéros pour atteindre une puissance de 2 
    % (C'est plus rapide et ça aide pour la précision FFT)
    n = 2^nextpow2(n_orig);
    X = fft(x, n);
    
    % 2. Création du filtre de Hilbert
    h = zeros(n, 1);
    h(1) = 1;               % Composante DC
    h(2:n/2) = 2;           % Fréquences positives
    h(n/2+1) = 1;           % Nyquist
    % Les fréquences négatives restent à 0
    
    % 3. Transformation inverse
    z_full = ifft(X .* h);
    
    % 4. On ne garde que la partie qui correspond au signal original
    z = z_full(1:n_orig);
end