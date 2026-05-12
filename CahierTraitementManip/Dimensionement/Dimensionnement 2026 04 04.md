

# I - Les contraintes au labo

## A - Les contraintes pour caractériser 

1) Durée du pulse
	 J'ai regardé avec le critère objectif de sortie du bruit à epsilon prés, jusqu'au max et je prends 2 fois ca comme durée du pulse

| **Frequence kHz** | **Duré du pulse $\tau$ en µs pour **$\mathbf{\epsilon} = 1e-3$** | **idem pour 1e-4** | Distance à epsilon = 1e-3 et a v = 2400/2800 (longueur d onde environs) |
| ----------------- | ---------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------------- |
| 50                | 40                                                               | >                  | 9.6 cm / 11.2 cm                                                        |
| 100               | 20                                                               | 22                 | 5cm / 5.6                                                               |
| 150               | 13                                                               | 14.9               | 3 cm / 3.6                                                              |
| 200               | 10                                                               | 11.2               | 2.4 cm / 2.8                                                            |
	La durée du pulse est sans conséquence sur le pas d un sismogramme à partir du moment où on fait des mesure distinctes. 

2)  Largeur de l'échantillon pour ne pas avoir de réflexion pendant qu'on caractérise en transmission (2 pulses nécessaires)

	Ne pas oublier que les échantillons de caractérisation et de maquettes ne sont pas les même et n'ont pas besoin d'avoir les même dimensions. 
	Je vais distinguer les deux caractérisations. Je considère un bloque d'épaisseur $e$ et de largeur $L$
	![[Pasted image 20260404185951.png]]
	**Caractérisation en onde P**

	Dans cette config on ne veux pas que l'onde P qui arrive par réflexion sur le bord arrive avant l onde P directe qui a parcouru trois fois la largeur (ainsi on a réussis a avoir deux pulses) + la durée d un pulse comme ca on a pas de chevauchement du tout. 
	
	L'onde réfléchi parcours $d_r=\sqrt{L^2+e^2}$
	L'onde directe parcourt $d=3e$
	
	La condition s'écrit : $\sqrt{(L^2+e^2)}>3e + \delta x$ 
	Soit $L>\sqrt{8e^2 +\delta x ^2+6e \delta x }\approx 2\sqrt{2}e (1+0.5\cancel{\frac{\delta x^2}{e^2}}+3\frac{\delta x}{e})$
	 car A priori $\delta x<<e$ le terme barré c est peut etre un peu trop 
	Tester $2\sqrt{2} (e+\delta x)$ et voir si ca marche  

	**Caractérisation en onde S**
	
	L'onde S directe met 2 fois plus de temps il faut donc revoir ce critère et prendre une largeur  deux fois plus grande
	Soit $\boxed{L>2\sqrt{8e^2 +\delta x ^2+6e \delta x }}$

2) Pour une caractérisation en surface (pas obligé)

	Ce critère  n'a d'intérêt que si on veut caractériser en surface: 
	
	Distance parcouru jusqu'à l'offset max: $d=\sqrt{x^2 + 4e^2}$ 
	On veut que : 
	
		$$ \frac{d}{2v_S} > \frac{x}{v_S} <=> x_{max}<\sqrt{4/3} e < 1.15 e$$

## B - Les contraintes pour le sismogrammes de la maquette

J'ai commencé par un dimensionnement si on tape au centre mais en fait ca donne des dimensions importantes, il vaut donc mieux une configuration en symétrie par rapport au centre. 
![[Pasted image 20260404104019.png]]
### Si on tape au centre 
1) ODG pour ne pas être gêné par la réflexion au bord lors d'un sismogramme si on tape au centre 

	Faire un dessin on tape au centre l'offset est x, la taille de l'échantillon est $L=2R$ 
	
	Si on est large on ne veut qu'aucune onde atteigne le bords
	Il faut que l'onde R+S directe arrive avant que l'onde P, qui est 2 fois plus rapide, ne touche le bord de l'échantillon.
	
	Ainsi pour un échantillon rond sur lequel on excite au centre l'offset max c'est la moitié du rayon (L/4=R/2). 
	
	Si on est plus précis l'onde P qui se réfléchit arrive à l'offset max quand $t=R/2v_R + (R-x)/2v_R= (L-x)/2v_R$  et on veux que ca arrive après $x/v_R$ donc 
	
	$\boxed{x_{max} = L/3 - \delta x(f) = 2/3R - \delta x(f)}$ 
	
	**Ca c'est le raisonnement sans tenir compte de la duré du pulse, c'est un premier ODG qui va nous permettre d'avoir une première dimension qui va falloir augmenter d'une distance de pulse ou deux et vérifier que tout est cohérent.**

2
### Si on tape de façon symétriques 
1) Idem si on a une configuration symétrique par rapport au centre. 

2)  Multicouches: 2 couches 
	Pour la maquette final car on veut un milieu semi infini, mais dans les couches c est ok, (la réflexion au fond d une couche c'est même très bien).
	![[Pasted image 20260404110416.png]]
	**Premier critère**
		Il faut donc pour la maquette que l'onde la plus rapide qui se réfléchit au fond (donc onde P qui revient en vert ) arrive après l'onde la plus lente (onde S en rose) qui arrive à l'offset x (et ceux pour tout les offsets), il faut 
	
	$$\forall x ~~ \frac{(4e_1^2+x^2)}{v_s^2}< \frac{(4e^2+x^2)}{(2v_s)^2}$$
	Ce qui revient à dire : 
	$$\boxed{3x^2<e^2-4e_1^2} = 8e_2e-3e^2-4e_2^2$$
	ODG si on prends 
	$e=20cm$ et $e_1=10cm$ on obtiens $x_{max}=0$
	$e=30cm$ et $e_1=10cm$ on obtiens $x_{max}=12 cm$
	Ne pas oublier d'ajouter aux épaisseur la durée du pulse selon la fréquence, et vérifier si ca marche bien. 

	**Second critère**
		 Il Faut que l'onde en orange P arrive après l onde S mais aussi les allés retours plus rapide mais en fait cette onde orange arrive aprés celle en surface donc ouf pas de soucis si celle en surface est ok 
# II - Contrainte vis à vis du terrain à imager 

## A -  Dimensionnement naïf 
 On sonde jusqu'à 4 fois l'offset max en ODG
 Sur le terrain on a 
-  25 m d'offset max
- On a 48 Géophones un tout les 0.5 m. Ce paramètre est modulable a souhait on peut aller jusqu'à 2m entre les géophones donc aucun soucis. 
- Fréquence entre 5 et 100 ou 200 Hz disons une fréquence centrale à 50 Hz ou 100 Hz

Disons que nous faisons une maquette avec un offset de 25 cm ou la moitié de ca 
Le rapport d'aspect en longueur vaut $a_l=100$, ou 200
On rappel que le principe de similitude implique que $a_f=\frac{a_c}{a_l}$
Prenons un rapport d'aspect en vitesse de 1 par exemple, on a alors $a_f = 1/a_l = 1/100$
En fréquence centrale ca donne
$f_L= 100-200 \times f_T = 5-10kHz$ (lire 100 à 200 etc)

Ce n'est pas réaliste donc on va briser le principe de similitude en prenant plus de points de mesures au labo que sur le terrain. Il s'agit alors d'un compromis. 

# III - Proposition de maquettes 



## A- Maquette pour caractériser les propriétés en transmission

Quelques tentatives avant de comprendre que c est compliqué de ne pas avoir de reflexion dans le cas 
On reste sur le critère, quitte a vérifier après coup le vrai critère avec la racine:
$L> 5.6 e(1+3\delta x/2)$ avec $\delta x$ la durée du pulse 
Soit $e<\frac{L}{5.6}-3 \delta x$

Application numérique pour $L=50cm$ et $\delta x = 3cm$ (fréquence de 200 k Hz avec un poil d étalement)

e = -0.1 et zut 

Bon prenons juste L/5.6 on trouve 8 cm. Regardons si ca marche ...

Non j ai mieux 
````matlab
>> dx = 3; e = linspace(0,15);

>> figure; plot(e,2*sqrt(8*e.^2+dx^2+6*e*dx))
````
Si on veut que le pulse soit petit devant la taille de l échantillon on prends 15 cm et ca nous demande 90 cm de large c est beaucoup 

- > Regarder ce qui se passe avec létalement avec nos piezos plat je ne me souvient pas de l'ouverture ni de rien
On peut aussi faire du sismo il faut juste une epaisseur plus grande que la zone de travail et respecter le critere de non reflexion au bord. CF plus bas, avec L = 50 cm on peut travailler entre 5 cm et 20cm, on alors besoin d une epaisseur de  plus de 5 cm disons 10 pour être très large. Ca vaut le coup de regarder l acoustic hole. A etudier avant les achats
## B - Maquette à 2 couches
Disons qu'on veut une zone de travail de 20 cm et une profondeur totale de 7cm

Si on excite au centre de la maquette on a besoin de:
$40 +20*3/2 + \delta_x= 70 cm~+~  \delta_x$
- On a dit qu'on a besoin que l offset max c est 2/3 du rayon qui vaut 20 cm

Si on propose Pluto 50 cm mais qu on se place en symetrie par rapport au centre, shéma à 200 kHz duré du pulse 11 µs
![[Pasted image 20260404120219.png]]
l'offset c'est ok
Si la première couche fais $e_1 =3 cm$ que dois faire la seconde couches?
$e=\sqrt{3x_{max}^2+4e_1^2}=35~cm$
si $e_1 =6 cm$ on a 36 cm 
si $e_1 =10 cm$ on a besoin de 40 cm 
## C - Maquette à plus de couches 

