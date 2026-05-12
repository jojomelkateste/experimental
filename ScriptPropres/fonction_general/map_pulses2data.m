function [data_array] = map_pulses2data(freq,pulse_array,e,option)
    %MAP_PULSES2DATA Applique pulses2data à tout les paires de pulses 
    %   Detailed explanation goes here
    arguments
        freq 
        pulse_array 
        e 
        option.tronq   =  false % pour tronquer les frequence
        option.fc      = 1e6        % fc a donner pour les option de troncature
        option.delta_f = 0.1e6
    end
    tronq = option.tronq;
    fc = option.fc;
    delta_f = option.delta_f;

    N = length(pulse_array);
    N_bis = N*(N-1)/2;
    data_array = cell(1,N_bis);
    ind_data = 1;
    for i=1:N
        pulse1 = pulse_array{i};
        for j=i+1:N
            pulse2 = pulse_array{j};
            data_array{ind_data} = pulses2data(freq,pulse1,pulse2,e*(j-i), ...
                    "tronq",tronq,"delta_f",delta_f,"fc",fc);
            ind_data = ind_data+1;
            % j-1 e est le parcours parcouru par l onde
        end
    end
end

