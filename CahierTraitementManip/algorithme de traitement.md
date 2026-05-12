Sur l'ordi fixe: 
`C:\Users\Utilisateur\Desktop\Experimental
les scriptes propres se trouvent au path 
`C:\Users\Utilisateur\Desktop\Experimental\ScriptPropres`
Utiliser `exemple_2.m` pour l'exemple d'utilisation dans l'ordre on import les fichier des deux calibres (dans cette exemple je n'ai qu'un calibre donc je prend 2 fois la meme chose) 
- `name_c1`
-  `name_c2`
- `f_c` 
En plus des plot activable grâce à `plot_res` on sauvegarde les infos qu on met dans la variable `data2save` 

## Première étape
	La fonction `files2struct_2calibres`
	cette fonction sort un objet qui contient :
- `freq` les fréquences
- `temps` le temps
- ``emeteur``
	- `c1` donnée temporel debruité
	- `c2` idem pour le calibre 2
- `recepteur`
	- `c1` donnée temporel debruité
	- `c2` idem pour le calibre 2
- `pics` imformations sur les pics des pulses par la fonction de Hilbert 
	- `emeteur` puis `c1` `c2`
		- pic et pic_id
	- `recepteur` idem
	- `pic_concat` information concaténé:  les premier pics viennent du calibre 1 on les a tous jusqu'à `nb_sat` (nombre de pic saturé dans le second signal), le reste viennent du calibre 2. Ces pic servent pour le calulcul par le temps de vol.
		- pic_e pic_e_time pic_e_index et idem pour le récepteur 
Dans cette fonction le signal des l emeteur du recepteur pour les deux calibres sont affichés avec la detection d'enveloppe. Un débruitage passe bas d'ordre élevé est appliqué. 

# Traitement par temps de vol

utilisation de la fonction `pic2temp2vol`

Variables de sortis: 
vs_temp2vol,err_vs
ki_e ki_r  (ki avec emeteur et recepteur )
Q Q_err
Je ne garde que ki_r et son erreur

# Traitement par rapport spectral

Pour tout les paire de pics je calcule sur la grande gamme $delta_f=$ 

# Brouillon

```markdown

```matlab 
	plot(x,y)
	disp(1+"")
	