function y = lowpass_maison(x, f_coupure, fs, N)
    % x         : Signal d'entrée
    % f_coupure : Fréquence de coupure en Hz
    % fs        : Fréquence d'échantillonnage en Hz
    % N         : Ordre du filtre (longueur). Plus N est grand, plus c'est précis.
    
    if nargin < 4, N = 100; end
    if mod(N, 2) ~= 0, N = N + 1; end % N doit être pair pour un centrage parfait

    % 1. Fréquence de coupure normalisée (0 à 0.5)
    fc = f_coupure / fs;

    % 2. Création de la réponse impulsionnelle idéale (Sinc)
    % On crée un vecteur temps discret centré sur zéro
    n = -N/2 : N/2;
    
    % Calcul du sinc : sin(2*pi*fc*n) / (pi*n)
    % On gère le cas n=0 pour éviter la division par zéro (limite = 2*fc)
    h = zeros(size(n));
    idx_zero = (n == 0);
    h(idx_zero) = 2 * fc;
    h(~idx_zero) = sin(2 * pi * fc * n(~idx_zero)) ./ (pi * n(~idx_zero));

    % 3. Fenêtrage de Hamming (pour lisser la réponse)
    % Formule : 0.54 - 0.46 * cos(2*pi*n/N)
    w = 0.54 + 0.46 * cos(2 * pi * n / N);
    h = h .* w;

    % 4. Normalisation du gain (pour que le signal garde la même amplitude)
    h = h / sum(h);

    % 5. Application par convolution
    % 'same' garde la même taille que x et compense automatiquement le retard
    y = conv(x, h, 'same');
end


% % 1. Création d'un signal bruité
% fs = 1000;
% t = 0:1/fs:0.5;
% signal_pur = sin(2*pi*10*t); % 10 Hz
% bruit = 0.5 * sin(2*pi*300*t); % 300 Hz
% x = signal_pur + bruit;
% 
% % 2. Filtrage à 40 Hz avec notre fonction "maison"
% y = lowpass_maison(x, 40, fs, 100);
% 
% % 3. Graphique
% figure;
% subplot(2,1,1);
% plot(t, x); title('Signal Original (Bruité)'); grid on;
% subplot(2,1,2);
% plot(t, y, 'r', 'LineWidth', 1.5); title('Signal Filtré (Passe-bas 40Hz)'); grid on;