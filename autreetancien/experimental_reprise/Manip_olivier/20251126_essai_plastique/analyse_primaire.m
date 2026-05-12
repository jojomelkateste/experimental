clear all
load('reflexion_PMMA20mm.mat') % stoque dans src1
Ref = src1.Data; % signal de réference
fe = src1.SampleFrequency; % Frequence du générateur
load('transmission_PMMA20mm.mat')
Tr = src1.Data;
temps = (0:(length(Ref)-1))/fe; % temps 
figure
plot(temps,Ref,'LineWidth',1)
hold on
plot(temps,Tr,'r','LineWidth',1)

Tr1 = [Tr(1:400) zeros(1,400)];   % premier Pulse avec zero padding
Tr2 = [zeros(1,400) Tr(401:800)]; % Second Pulse
Nf = 4*length(Tr);      
S1TF = ifft(Tr1,Nf); % TF du premier pulse
S2TF = ifft(Tr2,Nf); % TF du second pulse
Freq = (0:(Nf-1))*fe/Nf;
figure
plot(Freq,abs(S1TF))
hold on
plot(Freq,abs(S2TF),'r')

R = S2TF./S1TF;% rapport entre les signaux
L = 0.04; % longeur traverse en 1 alle retour 2*20mm 
%imK = -log(abs(R))/L;
ReK = unwrap(angle(R))/L; % unvrap déroule la phase
v = 2*pi*Freq./ReK; % vitesse de phase mauvaise si on ne déroule pas la phase
vg = 2*pi*(Freq(2:end)-Freq(1:(end-1)))./(ReK(2:end)-ReK(1:(end-1))); %dw/dk
figure
plot(Freq(1:(end-1)),vg)
xlim([0.8 1.2])