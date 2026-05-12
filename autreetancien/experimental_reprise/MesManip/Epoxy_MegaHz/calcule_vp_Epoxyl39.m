

name1 = "Epoxy_l39mm_1Mhz.mat";
% Epoxy_l39mm_1Mhz_dezoom.mat
% Epoxy_L49mm_1Mhz.mat
% Epoxy_L49mm_1Mhz_dezoom.mat

load(name1)

uz_e = src1.Data; % emmetteur
uz_r = src2.Data; % recepteur
fe = src1.SampleFrequency; %frequence d'echentillonage
N = length(uz_e);
temps = (0:(N-1))/fe; % temps 
%freq = (0:(N-1))*fe/N;
freq = (-N/2:N/2-1)*(fe/N);

%% % plot en index
% plot du résultat en index 
figure;
hold on;
plot(uz_e)
% test de l envellope
env_r = abs(hilbert(uz_r));
plot(uz_r)
plot(env_r)
hold off;
xlabel("Index")
ylabel("u[V]")
%%
% La porteuse est bruité il faut lisser le signal avant de la calculer
% pour pouvoir faire une detection
% de pic


uz_r_fft = fft(uz_r);
figure;
plot(abs((uz_r_fft)))

uz_r_fft(1400:198600) = 0; % on enleve le bruit passe frequence 
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
t1 = t_pks(2);
t2 = t_pks(3);
t3 = t_pks(4);

p1 = pks(2);
p2 = pks(3);
p3 = pks(4);

% temps de vol 1 

dt1 = t2-t1;
dt2 = t3-t2;

disp("estimation de l erreur sur dt")
disp(abs(dt2-dt1)/dt1)

d = 2*39*1e-3; % entre un pic et un autre l onde a fait un alle retour

vp1 = d/dt1;
vp2 = d/dt2;
txt = sprintf('Avec le premier pic, le résultat est vp = %.2f', vp1);
disp(txt+" m/s")
txt = sprintf('Avec le second pic, le résultat est vp = %.2f', vp2);
disp(txt+" m/s")

erreur_l = 0.5e-3;
erreur_v = erreur_l/dt1;
disp("Estimation de l erreur sur la vitesse: "+erreur_v+ " m/s" )
disp("Soit une erreur relative de: "+ erreur_v/vp1*100 + " % ")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Avec une methode frequencielle
% On commence par isoler les pics

% pic1 
i_debut = 36390;
i_fin   = 41100;
pic1_r = zeros(1,N); % on copie le signal
pic1_r(i_debut:i_fin)  = (uz_r_clean(i_debut:i_fin)); 
pic1_fft = ifft(pic1_r);
pic1_fft_shift = fftshift(pic1_fft);
% pic2
i_debut = 42500;
i_fin   = 49000;
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
