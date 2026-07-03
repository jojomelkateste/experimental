# Série de Born élastodynamique — `BornPSVlambda_versionDIV_naive`

## Vue d'ensemble

Ce code implémente la série de Born pour le calcul du champ de déplacement PSV (P + SV) dans un milieu multicouche contenant une inclusion de contraste en λ (paramètre de Lamé). L'approche repose sur la formulation par divergence : le terme itératif s'écrit

```
terme_{n+1} = div(G^T) · D · χ · terme_n
```

où `G` est le propagateur de Green interne, `D` l'opérateur discret de divergence, et `χ = diag(δλ) · dS` la matrice de contraste. Le champ total aux détecteurs est reconstruit via `div(Ubm^T) · D · χ · Ua`.

---

## Arbre d'appel

```
BornPSVlambda_versionDIV_naive
├── zip_vectors
├── divGreenTrans                          (dispatcher)
│   ├── divGreenTrans_maillage             (méthode "maillage")
│   │   ├── build_neighbor_indices_geom    ← NOUVEAU
│   │   ├── derivee_voisinage              ← NOUVEAU
│   │   └── GreenPropagPSV
│   │       └── PSV_multicouche_main
│   └── divGreenTrans_direct               (méthode "direct")
│       └── PSV_multicouche_main
├── divUbmTransPSV                         (dispatcher)
│   ├── divUbmTransPSV_maillage            (méthode "maillage")
│   │   ├── build_neighbor_indices_geom    ← NOUVEAU
│   │   ├── derivee_voisinage              ← NOUVEAU
│   │   └── PSV_multicouche_main
│   └── divUbmTransPSV_direct              (méthode "direct")
│       └── PSV_multicouche_main
├── build_divergence_matrix_centre
│   └── build_neighbor_indices
└── PSV_multicouche_main                   (champ incident Ub, Ubl)
    └── gsm_mex (C++)
```

---

## Fonction principale

### `BornPSVlambda_versionDIV_naive`

**Fichier :** `Serie_Born_meca/BornPSVlambda_versionDIV_naive.m`

**Signature :**
```matlab
[Ual, Ubl, deltaUa_BORN, saved, n] = BornPSVlambda_versionDIV_naive(R, materiaux, d_lambda_input, dx, source, options)
```

**Entrées :**

| Paramètre | Type | Description |
|-----------|------|-------------|
| `R` | struct | Géométrie : `R.Xd, R.Zd` (détecteurs en surface), `R.Xi, R.Zi` (cellules de l'inclusion) |
| `materiaux` | struct/array | Description du milieu multicouche de fond |
| `d_lambda_input` | scalaire ou vecteur (N_I ou 2·N_I) | Contraste δλ. Scalaire = uniforme, vecteur N_I = identique en x et z, vecteur 2·N_I = entrelacé |
| `dx` | scalaire | Taille des pixels carrés de l'inclusion |
| `source` | name-value | `xs, zs, sx, sz, a, force_pi_a` — position et directivité de la source |
| `options` | name-value | `freq` (40), `Nkx1/2/3`, `Nborne1/2/3`, `do_fft`, `max_iter` (50), `eps_born` (1e-6), `n_iter_force` (0), `methode` ("direct" ou "maillage") |

**Sorties :**

| Sortie | Taille | Description |
|--------|--------|-------------|
| `Ual` | 2·N_D × 1 | Champ total aux détecteurs (entrelacé [ux;uz]) |
| `Ubl` | 2·N_D × 1 | Champ non perturbé (background) aux détecteurs |
| `deltaUa_BORN` | 2·N_D × 1 | Premier terme de Born seul (approximation linéaire) |
| `saved` | struct | Matrices réutilisables : `saved.divG`, `saved.divUbm`, `saved.chi`, `saved.Ub` |
| `n` | entier | Nombre d'itérations effectivement calculées |

---

## Fonctions de niveau 1 (appelées par le main)

### `divGreenTrans` — dispatcher div(G^T)

**Fichier :** `Serie_Born_meca/divGreenTrans.m`

```matlab
[Vbar] = divGreenTrans(Xi, Zi, materiaux, options)
```

| Entrée | Description |
|--------|-------------|
| `Xi, Zi` | Positions des N_I cellules de l'inclusion |
| `materiaux` | Milieu multicouche |
| `options.method` | `"maillage"` (par défaut) ou `"direct"` |
| `options.dx` | Pas de différence finie (uniquement si method="direct", défaut 1e-9) |
| `options.*` | Options PSV (freq, Nkx, do_fft, do_matlab_par) |

| Sortie | Taille | Description |
|--------|--------|-------------|
| `Vbar` | 2·N_I × N_I | Colonne k = div_r(G_k^T)(r) entrelacé [Vx;Vz] pour la source à la cellule k |

Aiguille vers `divGreenTrans_maillage` ou `divGreenTrans_direct` selon `method`.

---

### `divUbmTransPSV` — dispatcher div(Ubm^T)

**Fichier :** `Serie_Born_meca/divUbmTransPSV.m`

```matlab
[DivUbmT] = divUbmTransPSV(xs_list, Xi, Zi, materiaux, options)
```

| Entrée | Description |
|--------|-------------|
| `xs_list` | Positions x des N_D détecteurs (z=0 implicite) |
| `Xi, Zi` | Cellules de l'inclusion |
| `materiaux` | Milieu multicouche |
| `options.method` | `"maillage"` ou `"direct"` |

| Sortie | Taille | Description |
|--------|--------|-------------|
| `DivUbmT` | 2·N_D × N_I | Lignes 2i-1/2i = composantes x/z au détecteur i ; colonne p = point d'inclusion |

---

### `build_divergence_matrix_centre` — opérateur ∇·

**Fichier :** `fonctions/Derivation/build_divergence_matrix_centre.m`

```matlab
D = build_divergence_matrix_centre(Xv, Zv)
```

| Entrée | Description |
|--------|-------------|
| `Xv, Zv` | Positions des N cellules |

| Sortie | Taille | Description |
|--------|--------|-------------|
| `D` | N × 2N (sparse) | Opérateur divergence discret. Appliqué à un vecteur entrelacé [ux;uz], donne ∂x·ux + ∂z·uz |

Utilise `build_neighbor_indices` (ancien schéma à indices négatifs miroir). Non modifié.

---

### `zip_vectors` — entrelacement

**Fichier :** `fonctions/gestion_data/zip_vectors.m`

```matlab
V = zip_vectors(v1, v2)
```

Entrelace deux vecteurs de taille N en un vecteur 2N : `V = [v1(1); v2(1); v1(2); v2(2); ...]`.

---

### `PSV_multicouche_main` — propagateur PSV (noyau)

**Fichier :** `GSM_MEX/PSV_multicouche_main.m`

```matlab
[ux, uz] = PSV_multicouche_main(x_list, z_list, materiaux, name-value pairs...)
```

| Entrée | Description |
|--------|-------------|
| `x_list, z_list` | Points d'observation |
| `materiaux` | Milieu multicouche |
| `xs, zs` | Position source |
| `sx, sz` | Composantes de force |
| `a` | Rayon de la source (0 = ponctuelle) |
| `freq, Nkx1/2/3, Nborne1/2/3` | Paramètres d'intégration |
| `use_cache, reset_cache` | Gestion du cache C++ multiniveau |

| Sortie | Description |
|--------|-------------|
| `ux, uz` | Déplacements aux points d'observation |

Interface MATLAB vers le MEX C++ `gsm_mex`. Goulot d'étranglement du calcul (intégration en nombre d'onde).

---

## Fonctions de niveau 2 (implémentations des dispatchers)

### `divGreenTrans_maillage` — div(G^T) sur grille

**Fichier :** `Serie_Born_meca/divGreenTrans_maillage.m`

```matlab
[Vbar] = divGreenTrans_maillage(Xi, Zi, materiaux, options)
```

Réutilise les valeurs de G déjà calculées par `GreenPropagPSV` (pas d'appel PSV supplémentaire). Calcule les dérivées par différences finies sur le maillage de l'inclusion via `derivee_voisinage` + `build_neighbor_indices_geom`.

Mapping physique : `Vx = ∂x(Gxx) + ∂z(Gxz)`, `Vz = ∂x(Gzx) + ∂z(Gzz)`.

---

### `divGreenTrans_direct` — div(G^T) par décalage

**Fichier :** `Serie_Born_meca/divGreenTrans_direct.m`

```matlab
[Vbar] = divGreenTrans_direct(Xi, Zi, materiaux, dx, options)
```

Calcule div(G^T) en décalant analytiquement le point d'observation de ±dx en x et z. Nécessite 8 appels PSV supplémentaires par source (4 directions × 2 composantes). Robuste par construction (insensible à la topologie du maillage).

---

### `divUbmTransPSV_maillage` — div(Ubm^T) sur grille

**Fichier :** `Serie_Born_meca/divUbmTransPSV_maillage.m`

```matlab
[DivUbmT] = divUbmTransPSV_maillage(xs_list, Xi, Zi, materiaux, options)
```

Même principe que `divGreenTrans_maillage` mais pour le propagateur extérieur Ubm. Calcule 4 champs UBM par détecteur (sx/sz = 1,0 et 0,1), puis dérive sur le maillage.

---

### `divUbmTransPSV_direct` — div(Ubm^T) par décalage

**Fichier :** `Serie_Born_meca/divUbmTransPSV_direct.m`

```matlab
[DivUbmT] = divUbmTransPSV_direct(xs_list, Xi, Zi, materiaux, dx, options)
```

Même principe que `divGreenTrans_direct` mais pour Ubm. 8 appels PSV par détecteur.

---

## Fonctions de niveau 3 (utilitaires de dérivation)

### `build_neighbor_indices_geom` — voisinage géométrique ← NOUVEAU

**Fichier :** `fonctions/Derivation/build_neighbor_indices_geom.m`

```matlab
[n_xp, n_xm, n_xp2, n_xm2, n_zp, n_zm, n_zp2, n_zm2] = build_neighbor_indices_geom(X, Z, dx)
```

| Entrée | Description |
|--------|-------------|
| `X, Z` | Positions des N cellules |
| `dx` | Pas de grille |

| Sortie | Description |
|--------|-------------|
| `n_xp` | Indice du voisin à (x+dx, z), 0 si absent |
| `n_xm` | Indice du voisin à (x−dx, z), 0 si absent |
| `n_xp2` | Indice du voisin à (x+2dx, z), 0 si absent |
| `n_xm2` | Indice du voisin à (x−2dx, z), 0 si absent |
| `n_zp/n_zm/n_zp2/n_zm2` | Idem en direction z |

Construit une table de hachage `(round(x/dx), round(z/dx))` → indice, puis cherche les 8 voisins par lookup. Robuste multi-morceaux : un voisin qui n'existe pas dans le maillage donne 0 (pas de faux voisin « à travers le vide »).

---

### `derivee_voisinage` — dérivée discrète cascade O(dx²) ← NOUVEAU

**Fichier :** `fonctions/Derivation/derivee_voisinage.m`

```matlab
dF = derivee_voisinage(F, n_p, n_m, n_p2, n_m2, dx)
```

| Entrée | Description |
|--------|-------------|
| `F` | Champ scalaire (N × 1) |
| `n_p, n_m` | Indices voisins ±1 pas (0 = absent) |
| `n_p2, n_m2` | Indices voisins ±2 pas (0 = absent) |
| `dx` | Pas de grille |

| Sortie | Description |
|--------|-------------|
| `dF` | Dérivée discrète (N × 1) |

Cascade de 6 cas (premier applicable l'emporte) :

| Cas | Condition | Formule | Ordre |
|-----|-----------|---------|-------|
| 1 | 2 voisins ±1 | centré `(F₊₁ − F₋₁) / 2dx` | O(dx²) |
| 2 | voisin +1 et +2, pas de −1 | forward `(−3F + 4F₊₁ − F₊₂) / 2dx` | O(dx²) |
| 3 | voisin −1 et −2, pas de +1 | backward `(3F − 4F₋₁ + F₋₂) / 2dx` | O(dx²) |
| 4 | voisin +1 seul | forward `(F₊₁ − F) / dx` | O(dx) |
| 5 | voisin −1 seul | backward `(F − F₋₁) / dx` | O(dx) |
| 6 | aucun voisin | `0` | — |

---

### `build_neighbor_indices` — voisinage par lignes (ancien)

**Fichier :** `fonctions/Derivation/build_neighbor_indices.m`

```matlab
[i_nextX, i_nextZ, i_prevX, i_prevZ] = build_neighbor_indices(Xv, Zv)
```

Construit les voisins ±1 en x et z par parcours séquentiel des lignes de Z constant. Un indice négatif signale un bord (miroir). Utilisé uniquement par `build_divergence_matrix_centre` (opérateur ∇·u pour la série de Born). Non modifié.

---

### `GreenPropagPSV` — assemblage du propagateur de Green

**Fichier :** `Serie_Born_meca/BornPSV/GreenPropagPSV.m`

```matlab
[G, Gxx_all, Gxz_all, Gzx_all, Gzz_all] = GreenPropagPSV(Xi, Zi, materiaux, options)
```

| Sortie | Taille | Description |
|--------|--------|-------------|
| `G` | 2·N_I × 2·N_I | Matrice de Green complète (entrelacée) |
| `Gxx_all` | cell(N_I,1) | Composante xx pour chaque source (vecteurs N_I × 1) |
| `Gxz_all, Gzx_all, Gzz_all` | cell(N_I,1) | Idem pour les autres composantes |

Appelle `PSV_multicouche_main` en deux passes (sx=1/sz=0 puis sx=0/sz=1), groupées par z-source pour maximiser la réutilisation du cache C++.

---

## Optimisations apportées

### 1. Schéma de dérivée au bord : O(dx) → O(dx²)

**Avant :** l'ancien `derivee_voisinage` (sous-fonction locale) utilisait un schéma décentré à 1 point au bord (forward ou backward d'ordre 1). Sur un disque, l'erreur au bord atteignait ~580× l'erreur intérieure.

**Après :** la nouvelle `derivee_voisinage` utilise une cascade décentrée à 3 points au bord (`−3F + 4F₊₁ − F₊₂` / `3F − 4F₋₁ + F₋₂`), qui élimine le terme en F'' et maintient l'ordre O(dx²) même au bord. Le repli à O(dx) n'intervient que pour les pointes ou isthmes d'une cellule de large.

### 2. Voisinage géométrique : robustesse multi-morceaux

**Avant :** `build_neighbor_indices` encode les bords par un indice négatif « miroir » (le voisin absent est remplacé par le voisin opposé). Ce mécanisme suppose un bord aligné sur la grille et crée de faux voisins entre deux inclusions disjointes (une sphère « voit » l'autre à travers le vide).

**Après :** `build_neighbor_indices_geom` utilise une table de hachage position→indice. Seules les cellules réellement présentes dans le maillage sont des voisins valides. Un voisin absent donne l'indice 0, ce qui est correctement traité par la cascade de `derivee_voisinage`. Aucun faux voisin inter-morceaux.

### 3. Élimination de la duplication de code

**Avant :** `derivee_voisinage` était dupliquée comme sous-fonction locale dans `divGreenTrans_maillage.m` ET `divUbmTransPSV_maillage.m` (copie identique).

**Après :** une seule implémentation dans `fonctions/Derivation/derivee_voisinage.m`, appelée par les deux fichiers.

---

## Choix de méthode : `"maillage"` vs `"direct"`

| Critère | `"maillage"` | `"direct"` |
|---------|-------------|-----------|
| Principe | Dérivées sur la grille d'inclusion | Décalage analytique du point d'observation |
| Appels PSV supplémentaires | 0 (pour divG) / N_D (pour divUbm) | 8 × N_I (pour divG) / 8 × N_D (pour divUbm) |
| Vitesse | Rapide | Lent |
| Robustesse topologique | Dépend du voisinage de grille | Insensible à la topologie |
| Précision au bord | O(dx²) avec le nouveau schéma | Exacte (pas de discrétisation) |
| Multi-morceaux | Correcte avec `build_neighbor_indices_geom` | Correcte par construction |

La méthode `"direct"` reste le défaut (`options.methode = "direct"` dans `BornPSVlambda_versionDIV_naive`). La méthode `"maillage"` est une accélération pour les gros maillages, une fois validée.
