
data =  load('exp3_pmma_transmission_100kHz.mat');
srce = data.src1;
srcr = data.src2;
fe = srce.SampleFrequency;
N = length(srce.Data);
temps = (0:(N-1))/fe; % temps 
freq = (-N/2:N/2-1)*(fe/N);

figure;
plot(temps,srce.Data)
hold on;
plot(temps,srcr.Data)

%% Traitement du signal detection

ur = remove_noise_bis(srcr.Data,freq,fe);
figure;
plot(srcr.Data,DisplayName="brute")
hold on
plot(ur,DisplayName="Netoye")
title("signal brut vs netoye")
legend;
xlabel("index")

%% Recuperation de deux "pulses" je ne sais pas encore si ce sont des pulses
N =length(temps);
e = 3e-3;
pulse_1 = zeros(1,N);
pulse_1(27023:31575) = ur(27023:31575);
pulse_2  = zeros(1,N);
pulse_2(31575:35526) = ur(31575:35526);

[M1] = pulses2data(freq,pulse_1,pulse_2,e,tronq=false);
%[M2] = pulses2data(freq,pulse_1,pulse_3,2*e,tronq=false);
figure;
plot(M1.freq,M1.vg,"DisplayName","pulse1 pulse2")
xlim([90e3,110e3])
% hold on;
% plot(M2.freq,M2.vg,"DisplayName","pulse2 pulse3")
title("tentative de traitement")