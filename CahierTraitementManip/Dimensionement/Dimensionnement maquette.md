
# Contrainte au labo
## Q0 Durée du pulse

J'ai regardé avec le critère objectif de sortie du bruit à epsilon prés, jusqu'au max et je prends 2 fois ca comme durée du pulse

| **Frequence kHz** | **Duré du pulse $\tau$ en µs pour **$\mathbf{\epsilon} = 1e-3$** | **idem pour 1e-4** | Distance à epsilon = 1e-3 et a v = 2400/2800 (longueur d onde environs) |
| ----------------- | ---------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------------- |
| 50                | 40                                                               | >                  | 9.6 cm / 11.2 cm                                                        |
| 100               | 20                                                               | 22                 | 5cm / 5.6                                                               |
| 150               | 13                                                               | 14.9               | 3 cm / 3.6                                                              |
| 200               | 10                                                               | 11.2               | 2.4 cm / 2.8                                                            |
La durée du pulse est sans conséquence sur le pas d un sismogramme à partir du moment où on fait des mesure distinctes. 
## Q1 Epaisseur pour séparer les pulses

Je prends $v=3000 m/s$ pour majorée la valeur et $v=2400 m/s$ pour la minoré attention je ne tiens pas compte de l'étalement. 

Pour séparer deux pulses il faut que la durée qui les sépare soit plus grande que la durée d'un pulse: 

| **Frequence kHz** | d pour **$v=3000m/s$** | **idem 2400** |
| ----------------- | ---------------------- | ------------- |
| 50                | 12                     | 9             |
| 100               | 6.6                    | 5             |
| 150               | 4                      | 3             |
| 200               | 3.3                    | 2.5           |


On notera $\delta x$ la distance qui correspond a la durée du pulse en supposant qu'il n' a pas d'étalement (multiplier par 2 ou 3 pour être large dans ce cas), il faut l'ajouter. 

## Q2 Largeur de l'échantillon pour ne pas avoir de réflexion pendant qu'on caractérise en transmission (2 pulses nécessaires)

Ne pas oublier que les échantillons de caractérisation et de maquettes ne sont pas les même et n'ont pas besoin d'avoir les même dimensions. 
Je vais distinguer les deux caractérisations. Je considère un bloque d'épaisseur $e$ et de largeur $L$
### Caractérisation en onde P

Dans cette config on ne veux pas que l'onde P qui arrive par réflexion sur le bord arrive avant l onde P directe qui a parcouru trois fois la largeur (ainsi on a réussis a avoir deux pulse) + la durée d un pulse comme ca on a pas de chevauchement du tout. 

L'onde réfléchi parcours $d_r=\sqrt{L^2+e^2}$
L'onde directe parcourt $d=3e$

La condition s'écrit : $\sqrt{(L^2+e^2)}>3e + v\delta t$ 
Soit $L>\sqrt{8e^2 +v^2\delta t ^2 +6e v \delta t} \approx 2\sqrt{2}e + 0.5*6e v \delta t$

En gros environs $L=3e +3v\delta t$a essayer ca et adapter si ca marche pas.


### Caractérisation en onde S

L'onde S directe met 2 fois plus de temps il faut donc revoir ce critère et prendre une largeur deux fois plus grande

## Q3 ODG pour ne pas être gêné par la réflexion au bord lors d'un sismogramme

Faire un dessin on tape au centre l'offset est x, la taille de l'échantillon est $L=2R$ 

Si on est large on ne veut qu'aucune onde atteigne le bords
Il faut que l'onde R+S directe arrive avant que l'onde P, qui est 2 fois plus rapide, ne touche le bord de l'échantillon.

Ainsi pour un échantillon rond sur lequel on excite au centre l'offset max c'est la moitié du rayon (L/4=R/2). 

Si on est plus précis l'onde P qui se réfléchit arrive à l'offset max quand $t=R/2v_R + (R-x)/2v_R= (L-x)/2v_R$  et on veux que ca arrive après $x/v_R$ donc 

$\boxed{x_{max} = L/3 = 2/3R}$ 

**Ca c'est le raisonnement sans tenir compte de la duré du pulse, c'est un premier ODG qui va nous permettre d'avoir une première dimension qui va falloir augmenter d'une distance de pulse ou deux et vérifier que tout est cohérent.**
## Q4 idem réflexion au fond

### Pour la maquette
Pour la maquette final car on veut un milieu semi infini, mais dans les couches c est ok, (la réflexion au fond d une couche c'est même très bien).
![[Pasted image 20260403163643.png]]
Il faut donc pour la maquette que l'onde la plus rapide qui se réfléchit au fond (donc onde P qui revient ) arrive après l'onde la plus lente (onde S) qui arrive à l'offset x (et ceux pour tout les offsets), il faut 

$$\forall x ~~ \frac{(4e_1^2+x^2)}{v_s^2}< \frac{(4e^2+x^2)}{(2v_s)^2}$$
Ce qui revient à dire : 
$$\boxed{3x^2<e^2-4e_1^2} = 8e_2e-3e^2-4e_2^2$$
ODG si on prends 
$e=20cm$ et $e_1=10cm$ on obtiens $x_{max}=0$
$e=30cm$ et $e_1=10cm$ on obtiens $x_{max}=12 cm$
Ne pas oublier d'ajouter aux épaisseur la durée du pulse selon la fréquence, et vérifier si ca marche bien. 
### Pour une caractérisation en surface (pas obligé)

Ce critère sera plus permissif car ce qu on veut c'est ne pas avoir de réflexion qui arrive n'a d'intérêt que si on veut caractériser en surface: 

 

Distance parcouru jusqu'à l'offset max: $d=\sqrt{x^2 + 4e^2}$ 
On veut que : 

	$$ \frac{d}{2v_R} > \frac{x}{v_R} <=> x_{max}<\sqrt{4/3} e < 1.15 e$$
Conclusion ce problème ne sera pas limitant par rapport au autres
# ODG maquette final 


## ODG Terrain

- On sonde jusqu'à 4 fois l'offset max en ODG
- On a 25 m d'offset max
- On a 48 Géophones un tout les 0.5 m. Ce parametre est modulable a souhait on peut aller jusqu'à 2m entre les géophones donc aucun soucis. 
- Fréquence entre 5 et 100 ou 200 Hz disons une fréquence centrale à 50 Hz ou 100 Hz

Disons que nous faisons une maquette avec un offset de 25 cm ou la moitié de ca 
Le rapport d'aspect en longueur vaut $a_l=100$, ou 200
On rappel que le principe de similitude implique que $a_f=\frac{a_c}{a_l}$
Prenons un rapport d'aspect en vitesse de 1 par exemple, on a alors $a_f = 1/a_l = 1/100$
En fréquence centrale ca donne
$f_L= 100-200 \times f_T = 5-10kHz$ (lire 100 à 200 etc)

Ce n'est pas réaliste donc on va briser le principe de similitude en prenant plus de points de mesures au labo que sur le terrain. Il s'agit alors d'un compromis. 

