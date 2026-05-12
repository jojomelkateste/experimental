# Réflexion au centre 

## Experience a 20 cm
Experience ici [ici](C:\Users\Utilisateur\Desktop\Experimental\Experiences\ponctuel\260220\PMMA centre)  20cmecart
CF cahier de manip (cahier jaune et pdf a coté P5 en bas ) 
Important filtrage du signal Buterworth d ordre 4 fc = 100 kHz bande passante +-40 kHz

Aperçu de l'expérience.
![[Pasted image 20260224094448.png]]
![[Pasted image 20260224093810.png]]
temps en micro secondes
Ordre de grandeur des vitesses 

$$v_p = 2800m/s ~~ v_s=1400 m/s  ~~ v_R=0.91v_s=1275m/s$$
Position des pics: 

- Je place le 0 (ne pas se fier a l image) au début du pulse bleu 
- Le temps dans le tableau est donné en µs 
- L intensité est en proportion de l'intensité maximum du signal reçu 
L intensité du max de l émission est à 16 µs

| temps debut | temps du max | temps de fin | intensite et remarques     | identification?                          |
| ----------- | ------------ | ------------ | -------------------------- | ---------------------------------------- |
| 6           | 30           | 53           | <=0.2                      | Onde P direct? Un peu avance.            |
| 92          | 138          | 160          | 0.88 puis pic a 1 a 147 µs | Onde P direct? + Onde R direct? +Onde S? |
| 160         | 180          | 195          | 0.79                       | Trajet direct onde R+S ?                 |
| 193         | 210          | 245          | 0.45                       | Onde S rebond cote perp                  |
| 280         | 300          | 315          | 0.08                       | Rebond sur cote onde R                   |
| 324         | 370          | 420          | 0.18                       |                                          |
### prévisions

L erreur est importante on ne regarde que les ODG

|                Description                | type d onde | d[cm] | temps prévu[µs] |
| :---------------------------------------: | :---------: | :---: | :-------------: |
|               Trajet direct               |      R      |  20   |       156       |
|               Trajet direct               |      P      | 20.4  |       72        |
|               Trajet direct               |      S      | 20.4  |       145       |
|          Rebond sur cotes ligne           |      R      |  35   |       274       |
| Rebond du coté perpendiculaire a la ligne |      R      | 53,85 |       422       |
|                   idem                    |      S      |  54   |       192       |
|                   idem                    |      P      |  54   |       385       |
|            4 reflexion direct             |      P      |  21   |       769       |
|                   idem                    |      S      |  21   |       549       |

# Transmission

Je veux avoir que l'onde P et l'onde S je me mets en transmission je m'attends donc à pouvoir differencier le pulse si en tennant compte des 45 µs de durée de pulse je peux les pulses arrivent a des moments différents
![[Pasted image 20260224105216 1.png]]