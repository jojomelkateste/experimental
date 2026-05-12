# Code qui marche pour générer des pulses


from array import array
from math import *
import sys
import time
import libtiepie
import csv
from printinfo import *

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
        scp.sample_rate = 1e5  # 0.1 MHz

        # Set record length:
        scp.record_length = 500000  # 500000 samples

        # Set pre sample ratio:
        scp.pre_sample_ratio = 0  # 0 %

        # For all channels:
        for ch in scp.channels:
            # Enable channel to measure it:
            ch.enabled = True

            # Set range:
            ch.range = 8  # 8 V

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
        ch.trigger.levels[0] = 0.5  # 50 %

        # Hysteresis:
        ch.trigger.hystereses[0] = 0.05  # 5 %

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
    gen.frequency = 100e3  # 10 kHz

    # Set amplitude:
    gen.amplitude = 2  # 2 V

    # Set offset:
    gen.offset = 0  # 0 V

    # Enable output:
    gen.output_enable = True
    
    gen.mode = libtiepie.GM_BURST_COUNT

    gen.burst_count = 15  # Modifier ce nombre pour définir le nombre de répétitions
    
    # Create signal array, and load it into the generator:
    data = array('f')

    for x in range(8192):
        data.append(cos((float(x)-1000)*2*3.14*1e2)*exp(-(float(x)-1000)**2 / 1000))

    gen.set_data(data)

    # Set burst mode: fixed number of repetitions


    # Print generator info:
    print_device_info(gen)


print(gen)
print(scp)
if True:
    # Start signal generation:
    scp.start()
    time.sleep(1)
    gen.start()

    # Attendre la fin de la génération
    while not scp.is_data_ready:
            time.sleep(0.01)  # 10 ms delay, to save CPU time

    # Get data:
    data = scp.get_data()

    # Output CSV data:
    with open('OscilloscopeBlock.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Sample'] + [f'Ch{i + 1}' for i in range(len(data))])  # Header
        for i in range(len(data[0])):
            writer.writerow([i] + [(data[j][i] if i < len(data[j]) else '') for j in range(len(data))])

        print()
        print(f'Data written to: {csvfile.name}')
            
    print('Signal generation completed.')

    gen.stop()
    gen.output_enable = False

    # Fermeture des appareils
    del gen
    del scp
    
