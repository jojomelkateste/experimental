d= load('Epoxy_1Mhz_longi.mat');
fe = d.src1.SampleFrequency;    
N = length(d.src1.Data);
temps = (0:(N-1))/fe; % tem

y = d.src1.Data;

figure;
plot(y);
%%
pulse1 = zeros(size(y));
pulse1(102006:104677)=y(102006:104677);
pulse2 = zeros(size(y));
pulse2(104677:107316)=y(104677:107316);
pulse3 = zeros(size(y));
pulse3(108298:110898)=y(108298:110898);

figure;
plot(temps,pulse1)
hold on;
plot(temps,pulse2)
plot(temps,pulse3)
e=4e-2;
freq = (-N/2:N/2-1)*(fe/N);
[data_array] = map_pulses2data(freq,{pulse1,pulse2,pulse3},e);
%%
freq = data_array{2}.freq;
vg = data_array{2}.vg;

figure;
plot(freq,vg)
xlim([0.8 1.2]*1e6)
%%
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
xlim([0.9 1.1]*1e6)
