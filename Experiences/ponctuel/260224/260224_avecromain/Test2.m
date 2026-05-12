%d = load('Epoxy_Filtre_peak_1Mhz_B80kHz.mat');
d = load('Epoxy_Filtre_peak_100khz_B80kHz.mat');

data = d.src1;

fe = data.SampleFrequency;    
N = length(data.Data);
temps = (0:(N-1))/fe; % tem

y = data.Data;
figure;
plot(y);

%%
pulse1 = zeros(size(y));
pulse1(202013:205583)=y(202013:205583);
pulse2 = zeros(size(y));
pulse2(205583:208511)=y(205583:208511);
pulse3 = zeros(size(y));
pulse3(208511:211194)=y(208511:211194);

figure;
plot(temps,pulse1)
hold on;
plot(temps,pulse2)
plot(temps,pulse3)

e=4e-2;
freq = (-N/2:N/2-1)*(fe/N);
[data_array] = map_pulses2data(freq,{pulse1,pulse2,pulse3},e);
figure;
hold on;
for i=1:3

    freq = data_array{i}.freq;
    vg = data_array{i}.vg;
    plot(freq,vg)
end
%xlim([0.9 1.1]*1e6)

xlim([0.9 1.1]*100e3)
