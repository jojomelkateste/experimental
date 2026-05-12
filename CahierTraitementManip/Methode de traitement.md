
## Détection d'enveloppe

Expliquer ici

## Débruitage 

expliquer ici

## Temps de vol 

### vitesse 
moyenne pour chaque calibre de la moyenne des $$\frac{d}{pic_{i+1}-pic_{i}}$$ calculée pour chaque calibre
Erreur estimée par standart deviation 

### Atténuation 

$Im(k)$ est obtenue par 
Régression linéaire sur le log des pics détecté par transformée de Hilbert (maison) en fonction de la distance parcourue :
$$Im(k) = -\log(pic)/d$$

erreur donnée par polyfit. Je prend celle qui a le plus de pics exploitables, en général celui du récepteur car celui de l'émetteur a déjà un pic en moins.  

#### Le facteur de qualité 
$$Q = \frac{2\pi f_c}{2v*Im(k)}$$
DISCUTION : PLUTOT PRENDRE la vrai fréquence centrale que la fréquence centrale nominale pour le facteur de qualité. 

