from array import array
from math import *
import sys
import time
import libtiepie
import csv
import pickle

import matplotlib.pyplot as plt
import numpy as np
import pickle 

fftshift = np.fft.fftshift;
fftfreq  = np.fft.fftfreq;
fft      = np.fft.fft; 
ifft     = np.fft.ifft;
plot = plt.plot;
figure = plt.figure;

#from send_g_pulse import send_g_pulse

# impiort des fonction persos
import sys
import os
# Chemin vers le dossier parent (mon_projet/)
parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(parent_dir)
# Maintenant, l'import fonctionne
from fonction_y.printinfo import *
#from fonction_y import *
from fonction_y.send_g_pulse import send_g_pulse

#commenter ce qui ne sert pas
#path du premier pulse qui a marche
path= '/home/manip/Documents/UtilistionTiePie/Version_Y/Y_experimental/saved_data/2025.5.5_15.28.12.pkl'

with open(path, 'rb') as f:
    data_loaded = pickle.load(f)
Ch1 = data_loaded['Ch1']
Ch2 =  data_loaded['Ch2']
se =  data_loaded['se']
param = data_loaded['param']
Fs_gen = param['Fs_gen']
Fs_osc = param['Fs_osc']
N_repet = param['N_repet']
F_repet = param['F_repet']
amplitudeGen = param['amplitudeGen']
amplitudeScope1 = param.get('amplitudeScope1') #evite les erreurs si data pas présente
amplitudeScope2 = param.get('amplitudeScope2')
NombreOscParPulse = param['NombreOscParPulse']
Freq_centrale = param['Freq_centrale']

t_gen = np.array( range(0,len(se)) )/Fs_gen
t_osc = np.array( range(0,len(Ch1)) )/Fs_osc
Ch1 = np.array(Ch1)
Ch2 = np.array(Ch2)
#%% definition des fonctions
def compute_fft(signal, fs):
    N = len(signal)
    fft_vals = np.fft.fft(signal)
    freqs = np.fft.fftfreq(N, d=1/fs)
    #return freqs[:N//2], (np.abs(fft_vals) / N)[:N//2]
    return freqs,fft_vals
#end def# On plot pour verifier 




def passe_bande(t,signal,f1,f2,plot_bol=False):
    """

    Parameters
    ----------
    t : time
    signal : signal
    f1 : frequence de coupure basse 
    f2 : frequence de coupure basse 

    Returns
    -------f1 = 20*10**3  #46*10**3
    f2 = 80*10**3

    titre = "signal netoye vs signal"

    clean_Ch2 = passe_bande(t_osc,Ch2,f1,f2)
    figure();
    plt.plot(t_osc,np.real(clean_Ch2))
    plt.plot(t_osc,np.real(Ch2))
    plt.title(titre + " Ch2")

    #netoyage du signale

    clean_Ch1 = passe_bande(t_osc,Ch1,f1,f2)
    figure();
    plt.plot(t_osc,np.real(clean_Ch1))
    #plt.plot(t_osc,np.real(Ch1))
    plt.title(titre + " Ch1")
    TYPE
        signal aprés passe bande
        fonction verifiee 
    """
    #res = np.array(signal)
    fs = 1/(t[1]-t[0])  # = Fs_gen
    freqs,res = compute_fft(signal, fs)
    
    #plot avant nettoyage
    if plot_bol:
        plt.figure()
        plt.plot(freqs,abs(res))
        plt.title("plot fft avant nettoyage ")
    
    res[freqs<-f2] = 0
    res[freqs>f2]= 0
    masque = (freqs > -f1) & (freqs < f1)
    res[masque]=0
    
    #res[(freqs>-f1)<0]=0
    
    #debug
    if plot_bol:
        plt.figure()
        plt.plot(freqs,abs(res))
        plt.title("plot a l'interieur de la fonction ")
    

    return np.fft.ifft(res)
#end def 

# # test de la fonction passe_bande
# avec le signal repete 
# t_gen = np.array( range(0,len(se)) )/Fs_gen
# clean_se = passe_bande(t_gen,se,1000,100000)
# plt.figure()
# # freqs = np.fft.fftfreq(N, d=1/Fs_gen)
# plt.plot(t_gen,np.real(clean_se))
# plt.plot(t_gen,np.real(se),'r--')
# plt.show()
# #fin de signal repete


#%% Plot du signal brute
plt.close('all')

#chanel 1
figure("CH1 ")
plt.subplot(2,1,1)
plt.plot(t_osc,Ch1)
plt.title("Channel 1")
plt.xlabel("t (s)")
plt.subplot(2,1,2)
freqs,fft_vals = compute_fft(Ch1, Fs_osc)
plt.plot(freqs,abs(fft_vals) )

#chanel 2
figure("CH2 ")
plt.subplot(2,1,1)
plt.plot(t_osc,Ch2)
plt.title("Channel 2")
plt.xlabel("t (s)")
plt.subplot(2,1,2)
freqs,fft_vals = compute_fft(Ch2, Fs_osc)
plt.plot(freqs,abs(fft_vals) )

plt.show()

# les deux chanel sur le meme graph 

figure("CH2 VS CH1")
plt.plot(t_osc,Ch2/max(Ch2))
plt.plot(t_osc,Ch1/max(Ch1))

# #plot independant
#  # # zone de plot de tout 
# plot_independant = False
# if plot_independant:
#     #le signal temporelle 
#     #plot de la chanel 2 le signal envoyé
#     t = np.array( range(0,len(Ch1)) )/Fs_osc#/Fs_gen # base de temps du génerateur  #je comprend pas pq c est Fs_osc et pas gen
#     plt.figure();
#     plt.plot(t,Ch2)
#     plt.title("Channel 2")
#     #plot de la chanel 2 le signal recu
#     #t = np.array( range(0,len(Ch1[0]) ) )/Fs_osc# base de temps de l'oscillo 
#     plt.figure();
#     plt.plot(t,Ch1)
#     plt.title("Channel 1")
#     freqs,fft_vals = compute_fft(Ch1, Fs_osc)
#     plt.figure()
#     plt.plot(freqs,abs(fft_vals) )
#     # 
#     plt.figure();
#     plt.plot(t_gen,se)
#     plt.title("signal")
#     freqs,fft_vals = compute_fft(se, Fs_gen)
#     plt.figure()
#     plt.plot(freqs,abs(fft_vals) )
    
# # plot ensemble 



#%% netoyage du signal 

# netoyage su signal du Ch2, ne change rien car propre bien sur
# # On plot pour verifier 
# f1 = 42*10**3  #46*10**3
# f2 = 60*10**3

# titre = "signal netoye vs signal"

# clean_Ch2 = passe_bande(t_osc,Ch2,f1,f2)
# figure();
# plt.plot(t_osc,np.real(clean_Ch2))
# plt.plot(t_osc,np.real(Ch2))
# plt.title(titre + " Ch2")

# #netoyage du signale

# clean_Ch1 = passe_bande(t_osc,Ch1,f1,f2)
# figure();
# plt.plot(t_osc,np.real(clean_Ch1))
# #plt.plot(t_osc,np.real(Ch1))
# plt.title(titre + " Ch1")


# #
# #
# #
# #
# #


#%% tentative avec déconvolution 



# freqs,Ch1_fft = compute_fft(Ch1, Fs_osc)
# freqs,Ch2_fft = compute_fft(Ch2, Fs_osc)
# Ch1_bis_fft = Ch1_fft*Ch2_fft;
# Ch1_bis = ifft(Ch1_bis_fft)
# figure();plot(t_osc,Ch1_bis/max(Ch1_bis))
# Ch2 = np.array(Ch2)
# plot(t_osc,Ch2/max(Ch2))