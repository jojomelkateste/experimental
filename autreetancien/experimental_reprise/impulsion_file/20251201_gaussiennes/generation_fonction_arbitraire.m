clear
% Fréquence du générateur (fréquence de répétition du signal)
fp = 1000;
% Période de répétition du signal
Tp = 1/fp;
%Nombre de points du signal
N = (0:(2^14-1)); % 2^14 par defaut
%Vecteur temporel
t = Tp/length(N)*N;
%Fréquence d'échantillonnage
fe = length(N)/Tp;
%Fréquence centrale du signal
fc = 1.5e6;
%variance de la Gaussienne
N_sigma = 7;
%sigmaf  = fc/N_sigma;
sigmaf  = 1e6/N_sigma;
%variance de la Gaussienne temporelle
sigmat = 1/2/pi/sigmaf;
%sigmat = sigmat/5; % tiens sur 10 ca ressemble a un ricker
%temps de "départ"
t0 = 6*sigmat;
%Signal
A = cos(2*pi*fc*(t-t0)).*exp(-(t-t0).^2/2/sigmat^2);
Nf = 4*length(N);
ATF = fftshift(fft(A,Nf));
Freq = ((-Nf/2:Nf/2-1) *fe/Nf);
figure
plot(t*1e6,A)
xlabel('temps \mu s')

figure;
plot(Freq,abs(ATF))
%%
%
%audiowrite('umpuslion_5_periodes_fc50kHz_frepetition_100Hz.wav',A,fe)
% if fc==1e5
%     %name = "ricker_gaussien_fc100kHz_frepetition_";
%     name = "gaussien_fc100kHz_frepetition_";
% elseif fc==1e6
%     name = "gaussien_fc1MHz_frepetition_";
% else
%     name = "Attention_freq";
% end
% name = "gaussien_fc"+
name = "gaussien_fc_1p50MHz_frep_";
name = name + fp +"Hz.wav" ;
audiowrite(name,A,fe)


%Ecriture d'un fichier .DAT
%tamere = fopen('tamerelachienne.tps','w');
%connard = fwrite(tamere,A);
%DA = fclose(tamere);




