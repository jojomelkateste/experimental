%clear
% Fréquence du générateur (fréquence de répétition du signal)
%fp = 1000;
fp = 1000;
% Période de répétition du signal
Tp = 1/fp;
%Nombre de points du signal
N = (0:(2^20-1)); % 2^14 par defaut
%Vecteur temporel
t = Tp/length(N)*N;
%Fréquence d'échantillonnage
fe = length(N)/Tp;
%Fréquence centrale du signal
fc_khz = 500;
fc = fc_khz*1e3;

% ricker
alpha = pi*fc;
beta  = 2e-5; %shift en temps

%Signal
A = (1-2 * alpha^2 * (t-beta).^2).*exp(- alpha^2 *(t - beta).^2) ;
Nf = 4*length(N);
ATF = fftshift(fft(A,Nf));
Freq = ((-Nf/2:Nf/2-1) *fe/Nf);
figure
plot(t*1e6,A)
xlabel('temps \mu s')

figure;     
plot(Freq,abs(ATF))

disp("length(A((t>=4e-6)&(t<=6e-6)))= "+length(A((t>=4e-6)&(t<=6e-6))))

%%
%name = "Ricker_test.wav";
name = "Ricker_fc_";
name = name + fc_khz + "_kHz_" + "fp_"+fp +".wav" ;
audiowrite(name,A,fe)