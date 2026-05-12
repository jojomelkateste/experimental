clear all
close all

addpath(genpath("C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_transmmission_MHZ"))
addpath("C:\Users\melka\Desktop\experimental_reprise\fonctions")
file1 = "20251128_essai001.mat"; % dezoom
file2 = "20251128_essai002.mat"; % zoom

%% On commence par le fichier 1 et on selectionne les pics
load(file1)


uz_e = src1.Data; % emmetteur
uz_r = src2.Data; % recepteur
fe = src1.SampleFrequency; %frequence d'echentillonage
N = length(uz_e);
temps = (0:(N-1))/fe; % temps 
freq = (-N/2:N/2-1)*(fe/N);
%% plot des resultats brutes
% figure;
% title("recepteur")
% hold on;
% plot(uz_r,'r--');
% hold off;
% 
% figure;
% hold on;
% title("emeteur")
% plot(uz_e,'r--');
% hold off;
%% lissage du signal 

[uz_r_clean] = remove_noise(uz_r,freq,fe);
[uz_e_clean] = remove_noise(uz_e,freq,fe);

% figure;
% hold on;
% title("recepteur debruité")
% plot(uz_r_clean);
% plot(uz_r,'r--');
% hold off;
% 
% figure;
% hold on;
% title("emeteur debruité")
% plot(uz_e_clean);
% plot(uz_e,'r--');
% hold off;
% 


%% Recuperation des pics 
MinPeakHeight = max(uz_e_clean)/5;%0.004
MinPeakDistance = 1e-5;% 1e-5
[pic_e,pic_times_e,pulse_array_e] = pulse_detection(temps,uz_e_clean,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);

MinPeakHeight = 0.04;%max(uz_r_clean)/30;%0.004
MinPeakDistance = 1e-5;% 1e-5
[pic_r,pic_times_r,pulse_array_r] = pulse_detection(temps,uz_r_clean,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);

%% on retiens des pics
