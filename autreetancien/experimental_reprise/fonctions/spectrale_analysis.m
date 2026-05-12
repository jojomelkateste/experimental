function [vg,Q_factor,freq_bis,reK,imK] = spectrale_analysis(pulse1,pulse2,freq,fc,d)
    %GROUPE_VELOCITY Summary of this function goes here
    %  pulse 1 et pulse 2 sont des pulse avec zero padding
    %  freq : array des frequences 
    %  fc : frequence centrale
    %  d : longeur parcouru (exemple 2e)
    %  vg est la vitesse de groupe calculée
 
    pulse1_fft = fftshift(ifft(pulse1));
    pulse2_fft = fftshift(ifft(pulse2));
    % pulse1_fft = fftshift(fft(pulse1));
    % pulse2_fft = fftshift(fft(pulse2));
    % Il peut il y avoir trop de point on ne prend que la zone d'interet
    pulse1_fft = pulse1_fft(freq>0.8*fc & freq<1.2*fc);
    pulse2_fft = pulse2_fft(freq>0.8*fc & freq<1.2*fc);
    freq_bis = freq(freq>0.8*fc & freq<1.2*fc);
    f = figure;
    hold on;
    plot(freq_bis,abs(pulse1_fft));
    plot(freq_bis,abs(pulse2_fft));
    hold off;
    title("verifier qu on a bien extrait les bon pic");
     % Crée un bouton "Continuer"
    btn = uicontrol('Style','pushbutton','String','Continuer',...
        'Position',[20 20 100 30],...
        'Callback',@(src,~) uiresume(f));

    uiwait(f);   % attend que uiresume soit appelé
    delete(btn); % supprime le bouton avant la prochaine boucle
    
    % 
    RS         = pulse2_fft(:)./pulse1_fft(:); % Rapport spectrale
    reK        = unwrap(angle(RS))/d; 
    imK        = -log(abs(RS))/d;
    % calcul de la vitesse de groupe d omega /dk
    vg = 2*pi*(freq_bis(2:end)-freq_bis(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));
    Q_factor = 0.5*reK./imK ;

    % figure de la vitesse de groupe
    figure;
    subplot(1,2,1)
    plot(freq_bis(2:end),vg);
    title("vitesse de groupe")
    subplot(1,2,2)
    plot(freq_bis,Q_factor);
    title("facteur de qualité 0.5 kr/ki")
end