clear
e = 2e-2;
%data = load('sauvegarde_a_2500_moy.mat'); F1
%data = load('sauvegarde_a_30k_moy.mat'); F2
data = load('sauvegarde_25mus_div_6k.mat');
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

%% plot e infice pour traitement a la vole a la main

figure;
plot(srcr.Data)

pulse_1 = zeros(1,N);
%pulse_1(20468:20752) = srcr.Data(20468:20752); % pour F1 et F2
pulse_1(14351:17741) = srcr.Data(14351:17741);
pulse_2 = zeros(1,N);
%pulse_2(20752:21057) = srcr.Data(20752:21057); % pour F1 et F2
pulse_2(17741:20582) = srcr.Data(17741:20582);
pulse_3 = zeros(1,N);
%pulse_3(21057:21343) = srcr.Data(21057:21343); % pour F1 et F2
pulse_3(20582:23545) = srcr.Data(20582:23545);


figure;
plot(pulse_1)
hold on;
plot(pulse_2)
plot(pulse_3)

%% Mesures
[M1] = pulses2data(freq,pulse_1,pulse_2,e,tronq=true);
[M2] = pulses2data(freq,pulse_2,pulse_3,e,tronq=true);
[M3] = pulses2data(freq,pulse_1,pulse_3,2*e,tronq=true);

figure;
plot(M1.freq,M1.vg,"DisplayName","pulse1 pulse2")
hold on;
plot(M2.freq,M2.vg,"DisplayName","pulse2 pulse3")
plot(M3.freq,M3.vg,"DisplayName","pulse1 pulse3")

legend

%% Fenetrage de hanning

T = 1.23e-5;
H1 = hann_test(temps,T,7.1e-5);%7.3
H2 = hann_test(temps,T,8.51e-5);
H3 = hann_test(temps,T,1.02e-4);

pulse1_hann = srcr.Data.*H1;
pulse2_hann = srcr.Data.*H2;
pulse3_hann = srcr.Data.*H3;

figure
subplot(2,1,1)
plot(temps,srcr.Data)
hold on;
plot(temps,pulse1_hann)
plot(temps,pulse2_hann)
plot(temps,pulse3_hann)
% hann_test = 0.54-0.46*cos(2*pi*temps/T);

subplot(2,1,2)
plot(temps,H1)
hold on;
plot(temps,H2)
plot(temps,H3)

%% Msure avec Fenettre de Hann

[M1_H] = pulses2data(freq,pulse1_hann,pulse2_hann,e,tronq=true);
[M2_H] = pulses2data(freq,pulse2_hann,pulse3_hann,e,tronq=true);
[M3_H] = pulses2data(freq,pulse1_hann,pulse3_hann,2*e,tronq=true);

figure;
plot(M1_H.freq,M1_H.vg,"DisplayName","pulse1 pulse2")
hold on;
plot(M2_H.freq,M2_H.vg,"DisplayName","pulse2 pulse3")
plot(M3_H.freq,M3_H.vg,"DisplayName","pulse1 pulse3")

function res = hann_test(t_a,T,t0)
    res = zeros(1,length(t_a));
    for i=1:length(t_a)
        t = t_a(i);
        if t>=t0 && t<=(t0+T)
            %res(i) = 0.54-0.46*cos(2*pi*(t-t0)/T);
            res(i) = 0.5-0.5*cos(2*pi*(t-t0)/T);
        end
    end

end
