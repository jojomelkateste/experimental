d = load('Experience2.mat');
fe = d.src1.SampleFrequency;    
N = length(d.src1.Data);
temps = (0:(N-1))/fe; % temps 
t_bis = temps*1e6-220.1;

Ue = d.src1.Data;
Ua = d.src2.Data;
Ufb = d.src3.Data; % filtre de buterworth sur Ua
Ufp = d.src4.Data; % filte peak fc = 100 kHz et Df = 80 khz
figure;
subplot(1,2,1)
hold on;
xline(18,DisplayName="Onde P prévu")
plot(t_bis,Ue/max(Ue),DisplayName="Ue normalise")
plot(t_bis,Ua/max(Ua),DisplayName="Uaveraged")
legend()
subplot(1,2,2)
hold on

xline(18,DisplayName="Onde P prévu")
xline(40,DisplayName="Onde R prévu")
plot(t_bis,Ue/max(Ue),DisplayName="Ue normalise")
plot(t_bis,Ufb/max(Ufb),DisplayName="Ua aprés filtre Buterworth")
plot(t_bis,Ufp/max(Ufb),DisplayName="Ua aprés filtre Peak")
xlabel("micro secondes")
legend()

%% Experience 3

d = load('Experience3_dx6cm.mat');
fe = d.src2.SampleFrequency;    
N = length(d.src2.Data);
temps = (0:(N-1))/fe; % temps 

t_bis = temps*1e6;

Ue = d.src1.Data; % zut je l ai efface 
Ua = d.src2.Data;
Ufb = d.src3.Data; % filtre de buterworth sur Ua
Ufp = d.src4.Data; % filte peak fc = 100 kHz et Df = 80 khz

figure;
subplot(1,2,1)
plot(temps,Ua)
title("")
%%
figure;
subplot(1,2,1)
hold on;
%xline(18,DisplayName="Onde P prévu")
%plot(temps,Ue/max(Ue),DisplayName="Ue normalise")
plot(temps,Ua/max(Ua),DisplayName="Uaveraged")
legend()
subplot(1,2,2)
hold on

%xline(18,DisplayName="Onde P prévu")
%xline(18,DisplayName="Onde R prévu")
%plot(temps,Ue/max(Ue),DisplayName="Ue normalise")
plot(temps,Ufb,DisplayName="Ua aprés filtre Buterworth")
plot(temps,Ufp,DisplayName="Ua aprés filtre Peak")
xlabel("micro secondes")
legend()