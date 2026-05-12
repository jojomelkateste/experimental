function [S_clean] = remove_noise(S,freq,fe)
    %REMOVE_NOISE enleve le bruit haute frequence du signal
    % Prend en parametres :
    % Le signal 
    % Les frequences associé pour trouver la frequence centrale
    % La frequence d echantillonage qu on pourrait retrouver avec les
    % frequences mais on la donc on l'utilise 
    arguments
        S (:,1) double   % signal colonne
        freq (1,:) double
        fe double
    end
    
    S_fft         = fftshift(fft(S));
    S_fft(freq<0) = 0;
    [M,M_ind]     = max(abs(S_fft)); % maximum de la Tf sur les freq positifs
    fc  = freq(M_ind);
    disp("frence centrale trouvé: "+fc )
    S_clean = lowpass(S,fc*1.9,fe);

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ancienne version 
    % Fait pour une gaussienne modulée par un cos
    %  Le signal haute frequence se trouve au centre de la fft, il y a
    %  symetrie donc il faut trouver i tel que:
    %       max(S(i:end-i
    %   Signal S 
    %   eps seuil du bruit en pourcentag
    % arguments
    %     S (:,1) double   % signal colonne
    %     eps double = 0.05 % valeur par défaut si non fourni
    %     plot_on logical = false
    % end
    % on va faire un simple passe bas
       %  S_fft = fft(S);
       %  N = length(S);
       %  [M,M_ind] = max(abs(S_fft)); % maximum de la TF sur la partie gauche
       %  condition = true;
       %  i = M_ind;
       %  while condition && i<N-i 
       %      m_centre  = max(abs(S_fft(i:N-i))); % maximum de la zone au centre 
       %      condition = (m_centre<eps*M);  % on a du bruit
       %      i = i+1;
       %  end 
       %  % Verification que epsilon n est pas trop petit
       %  if i == N-i
       %      warning("pas de zone au centre,epsilon trop petite")
       %  end
       %  S_fft(i:N-i) = 0;
       %  S_clean = real(ifft(S_fft));
       % 
       % % plot si demandé
       % if plot_on 
       %     figure;
       %     plot(S_fft)
       % end
end