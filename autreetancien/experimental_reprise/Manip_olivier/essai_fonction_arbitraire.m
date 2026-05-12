clear
% Fréquence du générateur (fréquence de répétition du signal)
fp = 1000;
% Période de répétition du signal
Tp = 1/fp;
%Nombre de points du signal
N = (0:(2^14-1));
%Vecteur temporel
t = Tp/length(N)*N;
%Fréquence d'échantillonnage
fe = length(N)/Tp;
%Fréquence centrale du signal
fc = 1e6;
%variance de la Gaussienne
sigmaf = fc/10;
%variance de la Gaussienne temporelle
sigmat = 1/2/pi/sigmaf;
%temps de "départ"
t0 = 3*sigmat;
%Signal
A = cos(2*pi*fc*(t-t0)).*exp(-(t-t0).^2/2/sigmat^2);
figure
plot(t*1e6,A)
xlabel('temps \mu s')
%%
%
%audiowrite('umpuslion_5_periodes_fc50kHz_frepetition_100Hz.wav',A,fe)

audiowrite('impulsion_5_periodes_fc1Mhz_frepetition_1000Hz.wav',A,fe)


%Ecriture d'un fichier .DAT
%tamere = fopen('tamerelachienne.tps','w');
%connard = fwrite(tamere,A);
%DA = fclose(tamere);




