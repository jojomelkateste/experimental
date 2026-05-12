d = load("Exp4_reproduction_petiechantillon_bis.mat");

ch1 = d.src1;% reception

fe = ch1.SampleFrequency;    
N = length(ch1.Data);
temps = (0:(N-1))/fe; % tem

ch1 = ch1.Data;
ch2 = d.src2.Data;% emission
Av1 = d.src3.Data;% moyenne brute
AvF1 = d.src4.Data; % Average sur filtre Peak 100 kHz pm 40kHz
AvF2 = d.src5.Data; % Average sur filtre Butterworth ordre 4 idem


figure;
subplot(1,2,1)
plot(temps,ch2);
title("Emission avant ampli")
subplot(1,2,2)
plot(temps,ch1); 
title("Reception brute")


figure;
subplot(3,1,1)
plot(temps,Av1); 
title("Moyenne brute")
subplot(3,1,2)
plot(temps,AvF1); 
title("Moyenne sur Filtre peak")
subplot(3,1,3)
plot(temps,AvF2); 
title("Moyenne sur Filtre Buterworth")
%%
figure;
sgtitle("En indices")
subplot(3,1,1)
plot(Av1); 
title("Moyenne brute")
subplot(3,1,2)
plot(AvF1); 
title("Moyenne sur Filtre peak")
subplot(3,1,3)
plot(AvF2); 
title("Moyenne sur Filtre Buterworth")

%% Zone de calcul des vitesses
e=4e-2;

freq = (-N/2:N/2-1)*(fe/N);
pulse1 = zeros(size(AvF2));
pulse1(205659:222651) = AvF2(205659:222651);
pulse2 = zeros(size(AvF2));
pulse2(222651:244379) = AvF2(222651:244379);

figure;
plot(temps,pulse1)
hold on;
plot(temps,pulse2)


[data_array] = map_pulses2data(freq,{pulse1,pulse2},e);

figure;
hold on;
for i=1:1
    freq = data_array{i}.freq;
    vg = data_array{i}.vg;
    plot(freq,vg)
end
xlim([0.9 1.1]*100e3)