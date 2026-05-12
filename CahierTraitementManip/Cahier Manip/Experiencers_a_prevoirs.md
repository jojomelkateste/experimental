    
# I - Expériences de reproductibilité + Mesure a 200 kHz

ecrire ici les question est les reponses auquel je dois répondre pour faire les manip
200 Khz échantillon qui va bien

# II - Etudes des interfaces

## Experience 1: Resine resine identique:
Q: voit on une interface
Protocol: Préparer bloque 5 par 5 cm puis couler un bloc de 5 cm attendre la semi réticulation puis couler par dessus 5cm. Vérifier qu on a pas de réflexion a l interface.
Prévoir 200 ml de résine et 100 ml de durcisseur 
## Experience 2: Idem 1 Mais avec résine chargée en dessous.
Q : a t on  -si exp 1 fructueuse- une interface idéale cf biblio
Prevoir idem 200 ml de résine et 100 ml de durcisseur 

## Experiences 3: Interface Marbre epoxy? Epoxy PMMA? 

Préparation à faire: cf biblio et claude : 
- brossage métallique grain 120 220 µm
- Etuvage pour pas d eau
- Dégraissage

# III - Préparation de la maquette

## Caractérisations
### Ponctuelle 
#### 100 Khz
- 5.5 cm d'épaisseurs 
- 21 cm de largeur min -> 25 cm c est bien 
Prévoir pour un échantillon circulaire : 5880 g de résine et 2940 g de durcisseur 

#### 200 KHz
- 3 cm épaisseur
- 12 cm de large 
On a a deja 1 de 4 * 14 qui convient parfaitement 
Prévoir pour un échantillon circulaire : 1040 g de résine et 520 g de durcisseur 

### Piezo plat 

Loi à sourcer  $$Z_{max}=R^2/\lambda - \lambda/4$$
``` matlab
C:\Users\Utilisateur\Desktop\Experimental\theorique
zone_non_etalement.m
```

A 200 kHz on a 2.8 cm  c est très peu.

## Maquette 

### Dimensionnement

Model terrain:
	Couche 1 : 
		- 2 m  (Quentin prenait 1.5m)
		- $\rho = 1700$ ; $vp =500$ ;  $vs =250$
	Couche 1 : 
		- 5 m (Quentin prenait 3.5m)
		-$\rho = 2000$ ; $vp =600$ ;  $vs =330$
	 Half space 
		 - $\rho = 2200$; $vp =1500$; $vs =500m/s$
offset max représenté : 50 m 

je défini les rapport d'aspect de façon a avoir des valeurs plus grand que 1 
**Travail a 100 kHz** a multiplier par 2 pour 200 kHz et diviser par 2 à 50
	$a_f = \frac{f_L}{f_T} = \frac{100~kHz}{50~Hz} =2000$

Pour la maquette idéale : 

	$a_L = \frac{L_T}{L_L}=a_f\frac{c_T}{c_L}=a_f a_c$

- $e_1 = 1mm \times a_c$   
- $e_2 = 2.5mm\times a_c$ 
- $OFFSET_{MAX} =25 mm \times a_c$ 

Si on prends de l epoxy 2500 m/s on est sur du facteur 5 

- Couche 1 : 5 mm epoxy version 1 
- Couche 2 : 12.5 mm epoxy version 2 (chargé) 
- Couche 3 : 10 a 20 cm (2ms d experience ok) roche a choisir selon ce qui fait une belle interface avec la résine
Dimension latéral 13 cm d'offset  
Prévoir 35 cm minimum soyons large à 40cm

Pour le 40 cm: 2.5 kG de résine et 1.3 kg de durcisseur large

