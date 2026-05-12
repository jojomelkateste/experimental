function [data] = pulses2data(freq,pulse1,pulse2,e,option)
        %PULSES2DATA prend 2 pulse récupéré par un quelconque fenetrage
        % les frequences qui correpondent, l epaisseur e 
        % et des options pour ne prendre que delta_f autour de la fréquence
        % central
        %   output: data qui contient
        %           
        arguments
            freq 
            pulse1 
            pulse2 
            e 
            option.tronq   =  false % pour tronquer les frequence
            option.fc      = 1e6        % fc a donner pour les option de troncature
            option.delta_f = 0.1e6
        end
        d = 2*e; 
        pulse1_fft = fftshift(ifft(pulse1));
        pulse2_fft = fftshift(ifft(pulse2));
        if option.tronq
        % Il peut il y avoir trop de point on ne prend que la zone d'interet
            df = option.delta_f;
            fc = option.fc;
            pulse1_fft = pulse1_fft(freq>fc-df & freq<fc+df);
            pulse2_fft = pulse2_fft(freq>fc-df & freq<fc+df);
            freq_bis = freq(freq>fc-df & freq<fc+df);
        else
            freq_bis = freq;
        end
        RS         = pulse2_fft(:)./pulse1_fft(:); % Rapport spectrale
        reK        = unwrap(angle(RS))/d; reK = reK'; % bonne dimension
        imK        = -log(abs(RS))/d;     imK = imK'; % bonne dimension
        % calcul de la vitesse de groupe d omega /dk
        vg = 2*pi*(freq_bis(2:end)-freq_bis(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));
        % Q_factor = 0.5*reK./imK ;
        Q_factor = 0.5*(2*pi*freq_bis(1:end-1)./vg)./imK(1:end-1);
        %%%%%
        % Resultats en enlevant un point pour en avoir atant
        data.freq     = freq_bis(1:end-1); % potentiellement restraint
        data.vg       = vg; % attention a 1 pt de moins que freq
        data.Q_factor = Q_factor; %idem 
        data.reK = reK(1:end-1);
        data.imK = imK(1:end-1);
end

