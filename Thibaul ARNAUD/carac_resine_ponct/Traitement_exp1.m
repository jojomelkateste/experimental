addpath("../")

d =  load('Exp1.mat');

ch1 = d.src2;% Réception non filtrée
fltch1 = d.src3;% Récepetion avec filre bas puis haut

fe = ch1.SampleFrequency;    
N = length(ch1.Data);
temps = (0:(N-1))/fe; % temps
freq = (-N/2:N/2-1)*(fe/N);
e = 4e-2; % Epaisseur de la raisine

%% On affiche nos signaux 

figure;

ch1 = ch1.Data;
ax1= subplot(2,1,1); % On affiche le signal sans filtres
plot(temps,ch1,'b')
grid on
hold on;

fltch1 = fltch1.Data;
ax2= subplot(2,1,2); % On affiche le signal filtré
plot(temps,fltch1,'r')
grid on 

%% En Echelle Log

figure;
ax1= subplot(2,1,1);
plot(temps,log(abs(ch1)),'b')
grid on
ax2= subplot(2,1,2);
plot(temps,log(abs(fltch1)),'r')
grid on 
%% On calculs nos différents pics

i1 = round(3.53e-5*fe) 
i2 = round(5.482e-5*fe)
pic1 = zeros(size(fltch1));
pic1(i1:i2) = fltch1(i1:i2);

[m1,t1_i] = max(abs(pic1));
t1 = temps(t1_i);

s1 = round(7.634e-5*fe)
s2 = round(8.727e-5*fe)
pic2 = zeros(size(fltch1));
pic2(s1:s2) = fltch1(s1:s2);

[m2,t2_i] = max(abs(pic2));
t2 = temps(t2_i);

b1 = round(1.09e-4*fe)
b2 = round(1.20e-4*fe)
pic3 = zeros(size(fltch1))
pic3(b1:b2) = fltch1(b1:b2)

[m3,t3_i] = max(abs(pic3));
t3 = temps(t3_i);

r1 = round(1.4e-4*fe)
r2 = round(1.5e-4*fe)
pic4 = zeros(size(fltch1))
pic4(r1:r2) = fltch1(r1:r2)

[m4,t4_i] = max(abs(pic4));
t4 = temps(t4_i);


figure;
plot(temps,abs(fltch1))
hold on;
plot(temps,abs(pic1))
plot(temps,abs(pic2))
plot(temps,abs(pic3))
plot(temps,abs(pic4))
scatter(t1,m1,'filled')
scatter(t2,m2,'filled')
scatter(t3,m3,'filled')
scatter(t4,m4,'filled')
grid on
%% On calcule la vitesse de groupe et le facteur de qualité pour le filtre

pics = {pic1,pic2,pic3,pic4}
temps = {t1,t2,t3,t4}

[data_array] = map_pulses2data(freq,pics,e);

figure;
hold on;

for k = 1:4 % On récupère la vitesse de groupe
    data = data_array{k};
    plot(data.freq,data.vg) % On trace les différetes courbes
    xlim([60e3,150e3])
end

for i = 1:length(temps)
    for j = i+1:length(temps)
        dt = temps{j} - temps{i};
        v = abs(2*(j-i)*e/dt)
        scatter(100e3,v,'filled')
    end
end
xlabel('Frequence (Hz)') %Axes
ylabel('Vitesse (m/s)')
grid on 

figure;
hold on;
for k = 1:4 % On récupère le facteur de qualité
    data = data_array{k};
    plot(data.freq,data.Q_factor) % On traces les courbes du Q_factor
    xlim([50e3,150e3]) % Intervalle pour la fréquence
end

xlabel('Frequence (Hz)') % Axes 
ylabel('Facteur de qualité Q')
grid on % Grille en fond 