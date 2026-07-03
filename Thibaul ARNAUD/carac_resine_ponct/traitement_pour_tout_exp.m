addpath("../")

d =  load('Exp1.mat');

ch1 = d.src2;% Réception non filtrée
fltch1 = d.src3;% Récepetion avec filre bas puis haut
frequence = 100e3; % Rentre la fréquence en Hz de ton signal et tout sera calculé (pense à load le bon fichier)
fe = ch1.SampleFrequency;    
N = length(ch1.Data);
temps = (0:(N-1))/fe; % temps
freq = (-N/2:N/2-1)*(fe/N);
e = 4e-2; % Epaisseur de la raisine

%% On affiche nos signaux 

figure;

ch1 = ch1.Data;
ax1= subplot(2,1,1); % On affiche le signal sans filtres
plot(temps,ch1,'b');
grid on;
title('Onde récupérée (brute)');
hold on;

fltch1 = fltch1.Data;
ax2= subplot(2,1,2); % On affiche le signal filtré
plot(temps,fltch1,'r');
grid on ;
title('Onde récupérée (filtrée)');

%% En Echelle Log

figure;
ax1= subplot(2,1,1);
plot(temps,log(abs(ch1)),'b');
grid on;
title('Onde récupérée (brute)');
ax2= subplot(2,1,2);
plot(temps,log(abs(fltch1)),'r');
grid on ;
title('Onde récupérée (filtrée)');
%% On calculs nos différents pics

i1 = round(3.53e-5*fe) ;
i2 = round(5.482e-5*fe);
pic1 = zeros(size(fltch1));
pic1(i1:i2) = fltch1(i1:i2);

[m1,t1_i] = max(abs(pic1));
t1 = temps(t1_i);

s1 = round(7.634e-5*fe);
s2 = round(8.727e-5*fe);
pic2 = zeros(size(fltch1));
pic2(s1:s2) = fltch1(s1:s2);

[m2,t2_i] = max(abs(pic2));
t2 = temps(t2_i);

b1 = round(1.09e-4*fe);
b2 = round(1.20e-4*fe);
pic3 = zeros(size(fltch1));
pic3(b1:b2) = fltch1(b1:b2);

[m3,t3_i] = max(abs(pic3));
t3 = temps(t3_i);

r1 = round(1.4e-4*fe);
r2 = round(1.5e-4*fe);
pic4 = zeros(size(fltch1));
pic4(r1:r2) = fltch1(r1:r2);

[m4,t4_i] = max(abs(pic4));
t4 = temps(t4_i);


figure;
plot(temps,abs(fltch1));
hold on;
plot(temps,abs(pic1));
plot(temps,abs(pic2));
plot(temps,abs(pic3));
plot(temps,abs(pic4));
scatter(t1,m1,'filled');
scatter(t2,m2,'filled');
scatter(t3,m3,'filled');
scatter(t4,m4,'filled');
grid on;
title('Vérification de nos pics');

%% On calcule la vitesse de groupe et le facteur de qualité pour le filtre

pics = {pic1,pic2,pic3,pic4};
temps = {t1,t2,t3,t4};
amplitude = {m1,m2,m3,m4}

[data_array] = map_pulses2data(freq,pics,e);

figure;
hold on;

for k = 1:4 % On récupère la vitesse de groupe
    data = data_array{k};
    plot(data.freq,data.vg); % On trace les différentes courbes
    xlim([frequence - 50e3,frequence + 50e3]);
end

for i = 1:length(temps)
    for j = i+1:length(temps)
        dt = temps{j} - temps{i};
        v = abs(2*(j-i)*e/dt);
        scatter(frequence,v,'filled');
    end
end
xlabel('Frequence (Hz)'); %Axes
ylabel('Vitesse (m/s)');
grid on ;
title('Vitesse de groupe');

figure;
hold on;
for k = 1:length(pics) % On récupère le facteur de qualité
    data = data_array{k};
    plot(data.freq,data.Q_factor); % On traces les courbes du Q_factor
    xlim([frequence - 50e3,frequence + 50e3]);% Intervalle pour la fréquence
end

xlabel('Frequence (Hz)'); % Axes 
ylabel('Facteur de qualité Q');
grid on; % Grille en fond
title('Facteur de Qualité');

figure;
hold on;

for k = 1:4 % On récupère la vitesse de groupe
    data = data_array{k};
    plot(data.freq,data.imK); % On trace les différentes courbes
    xlim([frequence - 50e3,frequence + 50e3]);
end

xlim([frequence - 50e3,frequence + 50e3]);
xlabel('Frequence (Hz)'); % Axes 
ylabel('Alpha (m^-1)');
grid on;% Grille en fond
title("Coefficients d'amortissement");
sort(alpha);

%% Graphique avec valeurs moyennes, minimum et maximum pour vg et le facteur de qualité 

all_vg = [];

for k = 1:length(pics)
    all_vg(:,k) = data_array{k}.vg;
end

vg_min = min(all_vg,[],2);
vg_mean = mean(all_vg,2);
vg_max = max(all_vg,[],2);

data.freq = data.freq(:);
vg_min = vg_min(:);
vg_mean = vg_mean(:);
vg_max = vg_max(:);

figure;
hold on ;

X = [data.freq ; flipud(data.freq)];
Y = [vg_min ; flipud(vg_max)];

fill(X, Y, [0.7 0.85 1], 'Edgecolor', 'none', 'FaceAlpha',0.4);

plot(data.freq,vg_min,'--b','LineWidth',0.5);
plot(data.freq,vg_mean,'-r','LineWidth',1);
plot(data.freq,vg_max,'--b','LineWidth',0.5);
xlim([frequence - 50e3,frequence + 50e3]);
legend('Zone Min-Max', 'Min', 'Moyenne', 'Max' );
title('Valeurs moyenne de la vitesse de groupe');
xlabel('Frequence (Hz)'); %Axes
ylabel('Vitesse (m/s)');
grid on ;
box on;
for i = 1:length(temps)
    for j = i+1:length(temps)
        dt = temps{j} - temps{i};
        v = abs(2*(j-i)*e/dt);
        scatter(frequence,v,'filled');
    end
end


all_Q = [];

for k = 1:length(pics)
    all_Q(:,k) = data_array{k}.Q_factor;
end

Q_min = min(all_Q,[],2);
Q_mean = mean(all_Q,2);
Q_max = max(all_Q,[],2);

data.freq = data.freq(:);
Q_min = Q_min(:);
Q_mean = Q_mean(:);
Q_max = Q_max(:);

figure;
hold on ;
Z = [data.freq ; flipud(data.freq)];
W = [Q_min ; flipud(Q_max)];

fill(Z, W, [0.7 0.85 1], 'Edgecolor', 'none', 'FaceAlpha',0.4);

plot(data.freq,Q_min,'--b','LineWidth',0.5);
plot(data.freq,Q_mean,'-r','LineWidth',1);
plot(data.freq,Q_max,'--b','LineWidth',0.5);
xlim([frequence - 50e3,frequence + 50e3]);
legend('Zone Min-Max', 'Min', 'Moyenne', 'Max');
title('Valeurs moyenne du facteur de qualité');
xlabel('Frequence (Hz)'); %Axes
ylabel('Facteur de qualité');
grid on ;
box on;

alpha = [];

for k = 1:length(pics)
    alpha(:,k) = data_array{k}.imK;
end

alpha_min = min(alpha,[],2);
alpha_mean = mean(alpha,2);
alpha_max = max(alpha,[],2);

data.freq = data.freq(:);
alpha_min = alpha_min(:);
alpha_mean = alpha_mean(:);
alpha_max = alpha_max(:);

figure;
hold on ;
T = [data.freq ; flipud(data.freq)];
U = [alpha_min ; flipud(alpha_max)];

fill(T, U, [0.7 0.85 1], 'Edgecolor', 'none', 'FaceAlpha',0.4);

plot(data.freq,alpha_min,'--b','LineWidth',0.5);
plot(data.freq,alpha_mean,'-r','LineWidth',1);
plot(data.freq,alpha_max,'--b','LineWidth',0.5);
xlim([frequence - 50e3,frequence + 50e3]);
xlabel('Frequence (Hz)'); %Axes
ylabel("Coefficient d'amortissemnt");
legend('Moyenne','Min','Max')
title("Valeur moyenne du coefficient d'amortissement")
grid on ;
box on;