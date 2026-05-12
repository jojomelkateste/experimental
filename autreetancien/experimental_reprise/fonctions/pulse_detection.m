function [pic,pic_times,pulse_array] = pulse_detection(t,S,options)
    %PIC_DETECTION Detecte les pulses gaussien dans un signal
    %   Detailed explanation goes here
    %disp("pas fait veillez utiliser [pks, locs] = findpeaks(signal);")
    
    arguments
        t
        S
        options.MinPeakHeight double = 0.004
        options.MinPeakDistance double = 1e-5
    end
    
    envelope = abs(hilbert(S));
    
    % detection pics
    MinPeakHeight = options.MinPeakHeight;
    MinPeakDistance = options.MinPeakDistance;
    %[pic,pic_indexes]  = findpeaks(envelope,'MinPeakHeight', MinPeakHeight,'MinPeakDistance', MinPeakDistance);
    %pic_times = t(pic_indexes); 
    [pic,pic_indexes]  = findpeaks(envelope,'MinPeakHeight', MinPeakHeight,'MinPeakDistance', MinPeakDistance);
    pic_times = t(pic_indexes); 
    % Verification avec l utilisateur que les pics sont au bon endroits
    % figure;
    % hold on;
    % title("Verifier les pics")
    % plot(t,S);
    % plot(t,envelope);
    % scatter(pic_times,pic);
    % hold off;
    
    N_pic = length(pic);
    % recupération grossierre des pulses
    pulse_array = cell(1,N_pic);
    i_deb = 1;
    %i_fin = int((pic_indexes(2)-pic_indexes(1))/2); % on suppose qu il y a au moins deux pulses et donc deux pic
    for n=1:N_pic-1
        i_fin = floor((pic_indexes(n+1)+pic_indexes(n))/2);
        pulse = zeros(1,length(S));
        pulse(i_deb:i_fin) = S(i_deb:i_fin); % on selectionne la zone
        pulse_array{n} = pulse;
        i_deb = i_fin;
    end
    % dernier pulse
    pulse = zeros(1,length(S));
    pulse(i_deb:end) = S(i_deb:end); % on selectionne la zone
    pulse_array{N_pic} = pulse;
    
    figure;
    hold on;
    title("Verifier les pics")
    plot(t,S);
    plot(t,envelope);
    scatter(pic_times,pic);
    hold off;

    % figure;
    % hold on;
    % for i=1:N_pic
    %     plot(t,pulse_array{i},"b")
    % end
    % %plot(t,S,"r--")
end