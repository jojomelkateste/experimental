# Code qui marche pour générer des pulses


from array import array
from math import *
import sys
import time
import libtiepie
import csv
#from printinfo import *
from fonction_y.printinfo import *
import matplotlib.pyplot as plt
import numpy as np

# Fs_gen = 1e6;             # Frequence dechantillonage du generateur de fonctions
# Fs_osc = Fs_gen*10;         # Frequence dechantillonage de loscillo
# N_repet = 50;             # Nombre de repetitions du signal (a verifier experimentalement !)
# F_repet = 100;              # Frequence de repetition 
# amplitudeGen = 12;  # amplitude de la tension du générateur max 12 V 
# amplitudeScope = 0.1; # amplitude de la tension de l'oscillo
# NombreOscParPulse = 5;
# Freq_centrale = 50e3;        # Frequence centrale de la gaussienne

# path = "/home/manip/Documents/UtilistionTiePie/Version_Y/Data/"
#file_name = path+"experience"+str(numero_exp)+".csv"

def send_g_pulse(param,file_name="",sleep_time = 0,info=""):
    #attendre pour avoir le temps de poser les piezos
    if sleep_time>0:
        time.sleep(sleep_time)
    # ################
    #numero_exp = 8;
    #plot_all =True;
    #info = "escalier petit avec gel couplant en transmission 50 repet";
    #Résine sur bloques de polystirene avec couplant signal envoye gaussienne a 50 kHz"
    Fs_gen = param['Fs_gen']
    Fs_osc = param['Fs_osc']
    N_repet = param['N_repet']
    F_repet = param['F_repet']
    amplitudeGen = param['amplitudeGen']
    amplitudeScope1 = param['amplitudeScope1']
    amplitudeScope2 = param['amplitudeScope2']
    NombreOscParPulse = param['NombreOscParPulse']
    Freq_centrale = param['Freq_centrale']

    
    N_ech = Fs_gen/F_repet;     # Definition de la longueur de lechantillon comme rapport de la duree totale de lechantillon et la periode dechantillonage
    
    
    SigmaEnTemps = NombreOscParPulse/Freq_centrale/12;#NombreOscParPulse/Freq_centrale/6;
    CentreEnTemps = 6*SigmaEnTemps;
    
    SigmaEnIndice = SigmaEnTemps*Fs_gen
    CentreEnIndice = CentreEnTemps*Fs_gen
    
    # Print library info:
    print_library_info()
    
    # Enable network search:
    libtiepie.network.auto_detect_enabled = True
    
    # Search for devices:
    libtiepie.device_list.update()
    
    # Try to open a generator with arbitrary support:
    
    gen = None
    for item in libtiepie.device_list:
        if item.can_open(libtiepie.DEVICETYPE_GENERATOR):
            gen = item.open_generator()
            if gen.signal_types & libtiepie.ST_ARBITRARY:
                break
            else:
                gen = None
                
                
    scp = None
    for item in libtiepie.device_list:
        if item.can_open(libtiepie.DEVICETYPE_OSCILLOSCOPE):
            scp = item.open_oscilloscope()
            if scp.measure_modes & libtiepie.MM_BLOCK:
                break
            else:
                scp = None
    
    if scp:
        try:
            # Set measure mode:
            scp.measure_mode = libtiepie.MM_BLOCK
    
            # Set sample frequency:
            scp.sample_rate = Fs_osc  # 0.1 MHz
    
            # Set record length:
            scp.record_length = int(N_repet/F_repet*Fs_osc) # 500000 samples
    
            # Set pre sample ratio:
            scp.pre_sample_ratio = 0  # 0 %
    
            # For all channels:
            numeroScope = 2
            for ch in scp.channels:
                print(ch)
                # Enable channel to measure it:
                ch.enabled = True
                if numeroScope==2:
                    # Set range:
                    ch.range = amplitudeScope1 # 8 V
                    numeroScope =1
                else:
                    ch.range = amplitudeScope2
    
                # Set coupling:
                ch.coupling = libtiepie.CK_DCV  # DC Volt
    
            # Set trigger timeout:
            scp.trigger.timeout = 100e-3  # 100 ms
    
            # Disable all channel trigger sources:
            for ch in scp.channels:
                ch.trigger.enabled = False
    
            # Setup channel trigger:
            ch = scp.channels[0]  # Ch 1
    
            # Enable trigger source:
            ch.trigger.enabled = True
    
            # Kind:
            ch.trigger.kind = libtiepie.TK_RISINGEDGE  # Rising edge
    
            # Level:
            # ch.trigger.levels[0] = 0.5  # 50 %
    
            # Hysteresis:
            # ch.trigger.hystereses[0] = 0.05  # 5 %
    
            # Print oscilloscope info:
            print_device_info(scp)
    
        except Exception as e:
            print(f'Exception: {e}')
            sys.exit(1)        
            
    if gen:
        # Set signal type:
        gen.signal_type = libtiepie.ST_ARBITRARY
    
        # Select frequency mode:
        gen.frequency_mode = libtiepie.FM_SAMPLERATE
    
        # Set sample frequency:
        gen.frequency = Fs_gen  # 10 kHz
    
        # Set amplitude:
        gen.amplitude = amplitudeGen  # 2 V
    
        # Set offset:
        gen.offset = 0  # 0 V
    
        # Enable output:
        gen.output_enable = True
        
        gen.mode = libtiepie.GM_BURST_COUNT
    
        gen.burst_count = N_repet  # Modifier ce nombre pour définir le nombre de répétitions
        
        # Create signal array, and load it into the generator:
        data = array('f')
    
        for x in range(int(N_ech)):
            data.append(cos((float(x)-CentreEnIndice)/Fs_gen*2*pi*Freq_centrale)*exp(-(float(x)-CentreEnIndice)**2 / (2*SigmaEnIndice**2)))
            #/Fs_gen car x indice de t et pas t
    
        gen.set_data(data)
        
        data_envoye = data;
        # Set burst mode: fixed number of repetitions
    
    
        # Print generator info:
        print_device_info(gen)
    
    
    print(gen)
    print(scp)
    if True:
        # Start signal generation:
        scp.start()
        time.sleep(0.1)
        gen.start()
    
        # Attendre la fin de la génération
        while not scp.is_data_ready:
                time.sleep(0.01)  # 10 ms delay, to save CPU time
    
        # Get data:
        data = scp.get_data()
        
        # si un chemin d'acces pour sauvegarder les données est indiqué on sauvegarde
        if len(file_name)>0: 
            # Output CSV data:
            with open(file_name, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                # Écrire les métadonnées
                writer.writerow(['Info', info])
                writer.writerow(['Fs_osc', Fs_osc])
                writer.writerow(['N_repet', N_repet])
                writer.writerow([])  # Ligne vide pour séparer
                writer.writerow(['Sample'] + [f'Ch{i + 1}' for i in range(len(data))])  # Header
                for i in range(len(data[0])):
                    writer.writerow([i] + [(data[j][i] if i < len(data[j]) else '') for j in range(len(data))])
        
                print()
                print(f'Data written to: {csvfile.name}')
            #end with
        #end if 
        print('Signal generation completed.')
    
        gen.stop()
        gen.output_enable = False
    
        # Fermeture des appareils
        del gen
        del scp
        #renvoie des data envoyer et lu par l'oscillo
        return data_envoye,data
#end def
##############################################################################

