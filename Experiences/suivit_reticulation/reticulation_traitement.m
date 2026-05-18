clear; 
close all;
e = 2e-2;
% on commence par repérer la base de temps 
% On veillera à avoir la même d'une expérience à l'autre
data = load('e1_exp1.mat');

src = data.src1;
fe = src.SampleFrequency;
N = length(src.Data);
temps = (0:(N-1))/fe; % temps 
freq = (-N/2:N/2-1)*(fe/N);

% nom des fichiers
e_list = ["e1","e2","e3","e6","e7","e11"];
base_name = e_list+"_exp";
description = ["Epodex 0%","SR8200","SR1670","Epodex +30%","Epodex +15%","SR8200 charge" ];

MinPeakDistance_list = [5526,5526,5526,5526,5526,5226];

%% Scripte pour afficher les data de la date du jour
numero_exp = 1;

vp_tv_list = zeros(1,length(e_list)); % pour récupérer le temps de vol 
figure;
for i=1:length(e_list)
    d =  load(base_name(i)+numero_exp+".mat");
    src = d.src1;
    [pulse_array,pic,id_pic] = signal2pulse(src.Data,8e-3,"MinPeakDistance",MinPeakDistance_list(i) ...
        ,"plot",false,"plot_pulse",false);
    % temps de vol avec les deux premier pulse seulement
    dt = temps(id_pic(2))-temps(id_pic(1));
    vp_tv = 2*e/dt; vp_tv_list(i) = vp_tv;
    %input("Verifier les pulses ")
    % on crée l info des vitesses etc 
    [data_array] = map_pulses2data(freq,pulse_array,e,"tronq",true);
    data_array = data_array{1};

    ff = data_array.freq;
    vp = data_array.vg;
    subplot(2,3,i)
    hold on;
    plot(ff,vp)
    scatter(1e6,vp_tv)
    title(description(i))
end

%% Affichage des vitesse mesurées
for i=1:length(e_list)
    disp(e_list(i)+" : " +description(i)+" vp = " + vp_tv_list(i) )
end
%% -- zone de test

% figure; 
% plot(src.Data);
% xlabel("Indices")
% MinPeakHeight = max(src.Data)/10;%8e-3;
% [pulse_array] = signal2pulse(src.Data,8e-3,"MinPeakDistance",MinPeakDistance_list(i));

