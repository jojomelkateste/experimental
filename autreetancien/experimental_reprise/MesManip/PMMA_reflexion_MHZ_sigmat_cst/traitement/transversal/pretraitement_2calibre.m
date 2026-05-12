%% definition du nom des deux fichiés celui zoome et l autre
addpath("C:\Users\melka\Desktop\experimental_reprise\fonctions")
namebase = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\transverse\";
name1 = namebase+"transverse_fc_0p5Mhz_c1.mat";
name2 = namebase+"transverse_fc_0p5Mhz_c2.mat";


fc = 0.5e6;
e = 0.02;

MinPeakHeight1  = 0.004;
MinPeakHeight2  = 0.004;

MinPeakDistance = 1e-5;

%% on load les donnée on on regarde comment faire 
% nomenclature 
% e: emeteur 
% r: recepteur
% c1: calibre1
% c2: calibre2
% calibre 1
S1 = load(name1);
srce_c1 = S1.src1; % emeteur
srcr_c1 = S1.src2; % recepteur 
%autre info
% autre info 
fe = srce_c1.SampleFrequency;

N = length(srce_c1.Data);
temps = (0:(N-1))/fe; % temps 
freq = (-N/2:N/2-1)*(fe/N);
%retour aux data


ue_c1 = srce_c1.Data; ue_c1 = remove_noise_bis(ue_c1,freq,fe); %champ de deplacement calibre 1
ur_c1 = srcr_c1.Data; ur_c1 = remove_noise_bis(ur_c1,freq,fe); 

S2 = load(name2);
srce_c2 = S2.src1; % emeteur
srcr_c2 = S2.src2; % recepteur 

ue_c2 = srce_c2.Data; ue_c2 = remove_noise_bis(ue_c2,freq,fe);   %champ de deplacement calibre 2
ur_c2 = srcr_c2.Data; ur_c2 = remove_noise_bis(ur_c2,freq,fe);


%% detection des pics


% pour le cas dezoom
% Les enveloppes
envelope_e_c1 = abs(hilbert(ue_c1));
envelope_r_c1 = abs(hilbert(ur_c1));
% les pic detectes
[pic_ec1,pic_time_ec1]  = findpeaks(envelope_e_c1,temps,'MinPeakHeight', MinPeakHeight1);%,'MinPeakDistance', MinPeakDistance);
[pic_rc1,pic_time_rc1]  = findpeaks(envelope_r_c1,temps,'MinPeakHeight', MinPeakHeight1);%,'MinPeakDistance', MinPeakDistance);

%pour le cas zoom 
% On essaye enleve d'abord le pic ecrasée
try 
    pulse_duration = pic_time_ec1(2)-pic_time_ec1(1) ; % c est cette ligne qui risque de planter d ou le try 
    %  pulse emeteur
    ue_c2_bis = ue_c2;                                 % on copie le signal
    t_max = pic_time_ec1(1)+pulse_duration/2;  % on repere le premier pic a l aide de l autr calibre
    [~,index_max] = min(abs(temps-t_max));     % indice pour le temps qui correspond au t_max
    ue_c2_bis(1:index_max) = 0;                % On elimine cette partie de la copie du signal
    envelope_e_c2 = abs(hilbert(ue_c2_bis));   % detection de l'enveloppe
    % pulse recepteur
    pulse_duration = pic_time_rc1(2)-pic_time_rc1(1) ;
    t_max = pic_time_rc1(1)+pulse_duration/2;
    [~,index_max] = min(abs(temps-t_max)); 
    ur_c2_bis = ur_c2;                                 % on copie le signal
    ur_c2_bis(1:index_max) = 0;                % On elimine cette partie de la copie du signal
    envelope_r_c2 = abs(hilbert(ur_c2_bis));   % detection de l'enveloppe
    
catch err
    % A FAIRE: Demander d entrer le pulse_duration ou de continuer comme si
    % de rien ete pour trouver ce temps relancer le code et l ecrire
    disp("catch de l erreur")
    envelope_e_c2 = abs(hilbert(ue_c1));
    envelope_r_c2 = abs(hilbert(ur_c1));
end

% La 
[pic_ec2,pic_time_ec2]  = findpeaks(envelope_e_c2,temps,'MinPeakHeight', MinPeakHeight1);%,'MinPeakDistance', MinPeakDistance);
[pic_rc2,pic_time_rc2]  = findpeaks(envelope_r_c2,temps,'MinPeakHeight', MinPeakHeight1);%,'MinPeakDistance', MinPeakDistance);


%% Affichage des 4 signaux et on vérifie les pics  
figure;
subplot(2,2,1)
plot(temps,ue_c1)
hold on;
plot(temps,envelope_e_c1)
scatter(pic_time_ec1,pic_ec1)
title("Emeteur calibre 1")

subplot(2,2,2)
plot(temps,ur_c1)
hold on;
plot(temps,envelope_r_c1)
scatter(pic_time_rc1,pic_rc1)
title("Recepteur calibre 1")

subplot(2,2,3)
hold on;
plot(temps,ue_c2)
plot(temps,envelope_e_c2)
scatter(pic_time_ec2,pic_ec2)
title("Emeteur calibre 2")

subplot(2,2,4)
plot(temps,ur_c2)
hold on;
plot(temps,envelope_r_c2)
scatter(pic_time_rc2,pic_rc2)
title("Recepteur calibre 2")

%% Tout ce qui a au dessus à mettre dans une fonction 
%% Ici récupérer tout les pulses
%% Faire le traitement