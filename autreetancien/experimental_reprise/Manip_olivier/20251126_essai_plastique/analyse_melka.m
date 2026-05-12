

name1 = "reflexion_PMMA20mm.mat";
name2 = 'transmission_PMMA20mm.mat';

load(name1)
uz_e = src1.Data; % emmetteur
load(name2)
uz_r = src1.Data; % recepteur
fe = src1.SampleFrequency; %frequence d'echentillonage
N = length(uz_e);
temps = (0:(N-1))/fe; % temps 
%freq = (0:(N-1))*fe/N;
freq = (-N/2:N/2-1)*(fe/N);


% plot du résultat en index 
figure;
hold on;
plot(uz_e)
env_e = abs(hilbert(uz_e));
plot(env_e,"r")
% test de l envellope
env_r = abs(hilbert(uz_r));
plot(uz_r)
plot(env_r)
hold off;
xlabel("Index")
ylabel("u[V]")
%%
% La porteuse du signal émis est bruité il faut lisser le signal avant de la calculer
% pour pouvoir faire une detection
% de pic


uz_r_fft = fft(uz_r);
figure;
plot(abs((uz_r_fft)))
%%
uz_r_fft(1000:9000) = 0; % on enleve le bruit passe frequence 
uz_r_clean = real(ifft(uz_r_fft));
env_test = abs(hilbert(uz_r_clean));
%[pks, locs] = findpeaks(env_test,temps,'MinPeakHeight', 0.01);
[pks, t_pks] = findpeaks(env_test,temps,'MinPeakHeight', 0.004,'MinPeakDistance', 1e-5);
    % 'MinPeakHeight', 0.01, ...        % seuil amplitude
    % 'MinPeakDistance', 100, ...       % distance min (100 échantillons)
    % 'MinPeakProminence', 0.02, ...    % proéminence min
    % 'MinPeakWidth', 50);              % largeur min


figure;
hold on;
plot(temps,(uz_r_clean),"b")
plot(temps,uz_r,"g.--")
plot(temps,env_test)
scatter(t_pks,pks)
%%
% parfait on a les bon point
% le premier pic n a pas d interet 
t1 = t_pks(1);
t2 = t_pks(2);
t3 = t_pks(3);
t4 = t_pks(4);
t5 = t_pks(5);
t6 = t_pks(6);

p1 = pks(1);
p2 = pks(2);
p3 = pks(3);
p4 = pks(4);
p5 = pks(5);
p6 = pks(6);
% temps de vol 1 

dt1 = t2-t1;
dt2 = t3-t2;
dt3 = t4-t3;
dt4 = t5-t4;
dt5 = t6-t5;

dt_list = [dt1,dt2,dt3,dt4,dt5];
figure;
scatter(1:5,dt_list);

%%
disp("estimation de l erreur sur dt")
disp("std : "+std(dt_list))
disp(abs(max(dt_list)-min(dt_list))/mean(dt_list))

%%
d = 2*20*1e-3; % entre un pic et un autre l onde a fait un alle retour
vp_list = zeros(1,length(dt_list));
for i=1:length(dt_list)
    vp_list(i) = d/dt_list(i);
    txt = sprintf('Avec le pic %.0f, le résultat est vp = %.2f',i, vp_list(i));
    disp(txt)
end

erreur_l = 0.5e-3;
erreur_v = erreur_l/dt1;
disp("Estimation de l erreur sur la vitesse: "+erreur_v+ " m/s" )
disp("Soit une erreur relative de: "+ erreur_v/mean(vp_list)*100 + " % ")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Avec une methode frequencielle
% On commence par isoler les pics

i_debut_list = [156 467 750 1050];
i_fin_list   = [405 670 1000 1300];
pic_array    = zeros(length(i_debut_list),N);
pic_fft_array= zeros(length(i_debut_list),N);
figure;
hold on;
for i=1:length(i_debut_list)
    i_debut = i_debut_list(i);
    i_fin   = i_fin_list(i);
    pic_array(i,i_debut:i_fin) = uz_r(i_debut:i_fin);
    pic_fft_array(i,:) = fftshift(ifft(pic_array(i,:)));
    % plot
    plot(temps,pic_array(i,:))
end
hold off

RS= pic_fft_array(2,:)./pic_fft_array(1,:); % Rapport spectrale
% RS(freq(i)) = R exp(ikl) = R exp(ik'l)exp(-k''l)
%en fait c est pas vrai il y a RimK = -log(abs(RS))/d ; % je n en ai pas besoin 
reK = unwrap(angle(RS))/d;

%v_phase = 2*pi*freq./reK;
vg1 = 2*pi*(freq(2:end)-freq(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));

figure("Name","vg premiers pics");
%plot(v_phase(50000:end))
plot(freq(1:(end-1)),vg1)
xlim([8e5 12e5])

%% avec le second pic
RS= pic_fft_array(3,:)./pic_fft_array(2,:);
reK = unwrap(angle(RS))/d;
vg2 = 2*pi*(freq(2:end)-freq(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));
figure("Name","vg second pics");
%plot(v_phase(50000:end))
plot(freq(1:(end-1)),vg2)
xlim([8e5 12e5])

%% avec le Troisieme pic
RS= pic_fft_array(4,:)./pic_fft_array(3,:);
reK = unwrap(angle(RS))/d;
vg3 = 2*pi*(freq(2:end)-freq(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));
figure("Name","vg troisieme pics");
%plot(v_phase(50000:end))
plot(freq(1:(end-1)),vg3)
xlim([8e5 12e5])

%% Les trois en semble
figure(Name="Dispertion des courbes")
hold on;
plot(freq(1:(end-1)),vg1)
plot(freq(1:(end-1)),vg2)
plot(freq(1:(end-1)),vg3)
hold off;
xlim([8e5 12e5])
legend()

%%
% pic1 
i_debut = 156;
i_fin   = 405;
pic1_r = zeros(1,N); % on copie le signal
pic1_r(i_debut:i_fin)  = (uz_r_clean(i_debut:i_fin)); 
pic1_fft = ifft(pic1_r);
pic1_fft_shift = fftshift(pic1_fft);
% pic2
i_debut = 467;
i_fin   = 670;
pic2_r = zeros(1,N); % on copie le signal
pic2_r(i_debut:i_fin)  = (uz_r_clean(i_debut:i_fin)); 
pic2_fft = ifft(pic2_r);
pic2_fft_shift = fftshift(pic2_fft);

figure;
hold on;
plot(pic1_r)
plot(pic2_r)
%plot(uz_r_clean,"b--")
hold off;

figure
title("les deux pics en frequences")
hold on; 
plot(freq,abs(pic1_fft_shift))
plot(freq,abs(pic2_fft_shift),"r")
hold off;

%%
RS= pic2_fft_shift./pic1_fft_shift; % Rapport spectrale
% RS(freq(i)) = R exp(ikl) = R exp(ik'l)exp(-k''l)
%en fait c est pas vrai il y a RimK = -log(abs(RS))/d ; % je n en ai pas besoin 
reK = unwrap(angle(RS))/d;

v_phase = 2*pi*freq./reK;
vg = 2*pi*(freq(2:end)-freq(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));

figure;
%plot(v_phase(50000:end))
plot(freq(1:(end-1)),vg)
xlim([8e5 12e5])
%%
% sauvegarde de vg
f = freq(1:(end-1));
vg1 = vg((8e5 < f) & (f<12e5));
% figure;
% title("Rapport spectrale");
% plot(freq,abs(RS))









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Poubelle
% % pr
% 
% figure;
% plot(abs(env_test));
% 
% env_fft = fft(env_test);
% env_fft(1:500)=0; % en eleve le bruit
% env_clean = abs(ifft(env_fft));
% 
% figure;
% plot(abs(fftshift(env_fft)));
% 
% figure;
% hold on;
% plot(env_r);
% plot(env_clean)
%%
% Recuperation de pulse en regardant graphiquement
% i_debut = 36390;
% i_fin   = 41100;
% pic1_r = zeros(1,N); % on copie le signal
% pic1_r(i_debut:i_fin)  = uz_r(i_debut:i_fin); 
% pic1_fft = ifft(pic1_r);
% pic1_fft_shift = fftshift(pic1_fft);
% % 
% pic1_enve = abs(hilbert(pic1_r));
% % on verifie
% figure(Name="pic1");
% subplot(1,2,1);
% hold on;
% plot(temps,pic1_r);
% plot(temps,pic1_enve);
% hold off;
% subplot(1,2,2);
% plot(freq,abs(pic1_fft_shift))







%%
% %% Extraction de l'envellope
% % cette methode de marche pas 
% % pic1_enve_fft = zeros(1,N);
% % pic1_enve_fft(abs(freq)>1e5) = pic1_fft_shift(abs(freq)>1e5);
% % %pic1_enve_fft = fftshift(pic1_enve_fft); % on annlule le fftshift
% % pic1_enve = fftshift(fft(pic1_enve_fft));
% pic1_enve = abs(hilbert(pic1_r));
% figure;
% plot(temps,pic1_enve)
% 
% %% 
% % second pic
% i_debut = 43000;
% i_fin   = 47400;
% pic2_r = zeros(1,N); % on copie le signal
% pic2_r(i_debut:i_fin)  = uz_r(i_debut:i_fin);
% 
% figure;
% hold on;
% plot(pic2_r)
% 
