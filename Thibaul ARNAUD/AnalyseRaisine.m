d =  load('Exp1raisine.mat');

ch1 = d.src1;% reception

fe = ch1.SampleFrequency;    
N = length(ch1.Data);
temps = (0:(N-1))/fe; % temps
freq = (-N/2:N/2-1)*(fe/N);
e = 2e-2;

ch1 = ch1.Data;
plot(temps,ch1,'b')

%% 
i1 = round(27.1e-6*fe)
i2 = round(36.7e-6*fe)
pic1 = zeros(size(ch1));
pic1(i1:i2) = ch1(i1:i2);

[m1,t1_i] = max(abs(pic1));
t1 = temps(t1_i);

s1 = round(44.2e-6*fe)
s2 = round(50.3e-6*fe)
pic2 = zeros(size(ch1));
pic2(s1:s2) = ch1(s1:s2);

[m2,t2_i] = max(abs(pic2));
t2 = temps(t2_i);

b1 = round(60.25e-6*fe)
b2 = round(65.4e-6*fe)
pic3 = zeros(size(ch1))
pic3(b1:b2) = ch1(b1:b2)

[m3,t3_i] = max(abs(pic3));
t3 = temps(t3_i);

figure;
plot(temps,abs(ch1))
hold on;
plot(temps,abs(pic1))
plot(temps,abs(pic2))
plot(temps,abs(pic3))
scatter(t1,m1)
scatter(t2,m2)
scatter(t3,m3)

%%

pics = {pic1,pic2,pic3}
temps = {t1,t2,t3}

[data_array] = map_pulses2data(freq,pics,e);

figure;
hold on;

for k = 1:3
    data = data_array{k};
    plot(data.freq,data.vg)
    xlim([900e3,1100e3])
end

for k = 1:length(temps) % Code de salopard (à optimiser) permet de placer toutes le combinaisons de vitesse avec les différebts temps 
    if ne(k,1)
        scatter(1e6,abs(2*e/(temps{k}-t1)))
    end
    if ne(k,2)
        scatter(1e6,abs(2*e/(temps{k}-t2)))
    end
    if ne(k,3)
        scatter(1e6,abs(2*e/(temps{k}-t3)))
    end
end

