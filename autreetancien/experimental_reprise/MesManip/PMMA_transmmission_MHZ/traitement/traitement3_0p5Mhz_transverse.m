% le but de ce scripte et d'aider à selectionner les pics et à les
% sauvegarder expériences par expérience

% FAIRE UN CTRL+F modifiable 

clear all
close all
e = 0.02; % etre plus precis plus tard
d = 2*e;
fc = 0.5e6;
omega = fc*2*pi;
addpath(genpath("C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_transmmission_MHZ"))
addpath("C:\Users\melka\Desktop\experimental_reprise\fonctions")
% Zone modifiable pour un fichier à l'autre
file1 = "20251128_essai035.mat"; % dezoom
file2 = "20251128_essai036.mat"; % zoom

% On commence par le fichier 1 et on selectionne les pics du signal recu
load(file1)
disp("selectionner les pics du recepteur")
uz_r = src2.Data;
fe = src1.SampleFrequency; %frequence d'echentillonage
N = length(uz_r);
temps = (0:(N-1))/fe; % temps 
freq = (-N/2:N/2-1)*(fe/N);
% On nettoie le signal 
[uz_r_clean] = remove_noise_bis(uz_r,freq,fe);

figure;
plot(uz_r_clean);

MinPeakHeight = 2e-3;%max(uz_r_clean)/30;%0.004
MinPeakDistance = 0.8e3;% distence en indice attention 
[pic_r,pic_times_r,pulse_array_r] = pulse_detection(temps,uz_r_clean,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);
% ici on peut faire un plot avec boucle for pour verifier que les
% pulse de pulse array sont les bons mais si les pic sont bon c est bon
f = figure;   % <-- stocke le handle de la figure
title("Vérifier les pulse et noter les indices du dernier pulse")
hold on;
for i = 1:length(pulse_array_r)
    plot(uz_r_clean);
    plot(pulse_array_r{i});

    % Crée un bouton "Continuer"
    btn = uicontrol('Style','pushbutton','String','Continuer',...
        'Position',[20 20 100 30],...
        'Callback',@(src,~) uiresume(f));

    uiwait(f);   % attend que uiresume soit appelé
    delete(btn); % supprime le bouton avant la prochaine boucle
    cla;         % nettoie l'axe
end
% Fenêtre de saisie avec inputdlg et conversion en entier
prompt = {'Entrez i1 (11364):', 'Entrez i2 (13177):'};
dlgtitle = 'Saisie de deux entiers';
dims = [1 30];
definput = {'0','0'};   % valeurs par défaut

answer = inputdlg(prompt, dlgtitle, dims, definput);

% Conversion en entiers
i1 = str2double(answer{1});
i2 = str2double(answer{2});


% Récupération sous forme d'entier
val = str2double(answer{1});
% on modifie le dernier pulse retenu
pulse = zeros(1,length(uz_r_clean));
pulse(i1:i2) = uz_r_clean(i1:i2);
pulse_array_r{end} =pulse;
plot(uz_r_clean);
plot(pulse_array_r{end});
% Crée un bouton "Continuer"
btn = uicontrol('Style','pushbutton','String','Continuer',...
    'Position',[20 20 100 30],...
    'Callback',@(src,~) uiresume(f));

uiwait(f);   % attend que uiresume soit appelé
delete(btn); % supprime le bouton avant la prochaine boucle
hold off;

% Pic qu on retiens 
pic_retenu_r.pic_time = pic_times_r(:);
pic_retenu_r.pic      = pic_r(:);
pic_retenu_r.pulse_array_r = pulse_array_r;

% On pourra ajouter les infos du second fichier ici plus tard
% TODO
%% Idem avec signal emis
uz_e = src1.Data;
[uz_e_clean] = remove_noise(uz_e,freq,fe);
MinPeakHeight = 2;%max(uz_r_clean)/30;%0.004
MinPeakDistance = 1e-5;% 1e-5
[pic_e,pic_times_e,pulse_array_e] = pulse_detection(temps,uz_e_clean,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);
pulse_array_e; % pour ne plus l avoir souligné 

% la il n y a qu un pic je l extrait manuelement 
pulse = zeros(1,length(uz_e_clean));
pulse(1:10400) = uz_e_clean(1:10400);
pulse_array_e = {pulse};
figure;
hold on;
plot(uz_e_clean);
plot(pulse,"r--");
title("Verifier que j ai bien extrait le pic")
hold off;
close all;
% Idem on peut utiliser le fichier zoome pour avoir plus de pic
% TODO
%% Traitement simple pour commencer, temps de vol et maximum (donc une seule frequence)
% Calcule de vp par temps de vol
[v_array] = temps_vol(pic_times_e,pic_times_r,e);

figure;
plot(v_array);
ylabel("vp 1 MHz ");
xlabel("index arbitraire");
title("temps de vol: Premier point emeteur recepteur, emeteur uniquement recepteur uniquement")

% Presentation des points
% env = abs(hilbert(log(uz_r_clean))); la detection d enveloppe comme ca ne
% marche pas 
%%
% regression lineaire
% A exp(-k'' d) d est le variable qui varie avec t

p = polyfit(pic_retenu_r.pic_time, log(pic_retenu_r.pic), 1);

% p(1) = pente, p(2) = ordonnée à l'origine
kpp = - p(1); % A exp(-k'' d) d est le variable qui varie avec t
disp("k'' = " + kpp +" m-1");

figure;
hold on;
plot(temps,log(uz_r_clean));
plot(temps,p(1)*temps+p(2));
%plot(env);
scatter(pic_retenu_r.pic_time, log(pic_retenu_r.pic))
%%
% Signal de la forme :
% S = A0 exp(-pi*f/Q/c *d)
% log(S) = log(A) - pi f / (Q c) l 
% Le premier point par exemple verifie
% log(S(1)) = ... - pi f / (Q c) *2e 

% % calcule de Q comme cela Q = omega/(2Ck'') 
d_pic = 2*e*(1:length(pic_retenu_r.pic_time));
p = polyfit(d_pic, log(pic_retenu_r.pic), 1);
% p(1) = pente, p(2) = ordonnée à l'origine
kpp = - p(1); % A exp(-k'' d) d est le variable qui varie avec t
disp("k'' = " + kpp +" m-1");


c = 1369;
Q = omega/(2*c*kpp);
disp("Q = "+ Q)
%autre formule Q = 0.5 kr/ki

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Version fréquentiel %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
% pulse1 = pic_retenu_r.pulse_array_r;
% 
% [vg,outputArg2] = spectrale_analysis(pulse1,pulse2,freq,d);
pulse1 = pic_retenu_r.pulse_array_r{1};
pulse2 = pic_retenu_r.pulse_array_r{2};
[vg,outputArg2] = spectrale_analysis(pulse1,pulse2,freq,fc,d);
% on a une fluctuation de 5% entre 0.9 et 1.1 Mhz



%% ANCIEN code
%% On améliore avec le second fichier 
% load(file2)
% disp("Ameliorer pour les pics utiles")
% uz_r = src2.Data;
% fe = src1.SampleFrequency; %frequence d'echentillonage
% N = length(uz_r);
% temps = (0:(N-1))/fe; % temps 
% freq = (-N/2:N/2-1)*(fe/N);
% % On nettoie le signal 
% [uz_r_clean] = remove_noise(uz_r,freq,fe);
% % On enleve la zone qui n est pas d interet
% % D abord on regarde et en suite on fait 
% figure;
% plot(uz_r_clean);
% uz_r_tronqu = uz_r_clean;
% uz_r_tronqu(1:13000) = 0;
% 
% MinPeakHeight = 0.004;%max(uz_r_clean)/30;%0.004
% MinPeakDistance = 1e-5;% 1e-5
% [pic_r,pic_times_r,pulse_array_r] = pulse_detection(temps,uz_r_clean,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);
% 
% figure;
% hold on;
% plot(uz_r_clean);
% scatter(pic_times_r,pic_r);

