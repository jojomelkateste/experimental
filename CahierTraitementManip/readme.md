# GSM MEX — Solveur multicouches (Global Stiffness Matrix)

## Branche FFT (do_fft=true) — implémentation et limitations

### Principe

L'intégration de Fourier inverse est normalement effectuée par quadrature Simpson sur la grille kx 3-intervalles. La branche FFT remplace cette quadrature par une IFFT sur une grille kx **uniforme**, afin de calculer tous les x en O(N log N) au lieu de O(Nkx × Nx).

### Paramètre d'activation

```matlab
[ux, uz] = gsm_mex(..., 'do_fft', true)
```

### Construction de la grille kx uniforme (`gsm_compute`)

```
fft_dkx  = kx_list[1] - kx_list[0]        % pas uniforme fourni par MATLAB
fft_NFFT = prochaine puissance de 2 ≥ Nkx  % sert uniquement à dimensionner le buffer IFFT
```

**La grille kx n'est pas reconstruite.** `in.kx_list` est utilisée telle quelle — c'est MATLAB qui a la responsabilité de fournir une grille uniforme. `NFFT` ne sert qu'à dimensionner le buffer interne de `fft_integrate_z` ; il n'entraîne aucune évaluation spectrale supplémentaire.

**Zero-padding implicite dans `fft_integrate_z`.** Le buffer IFFT de taille `M = 2*NFFT` est initialisé à zéro. Seules les `Nkx` premières entrées sont remplies à partir du spectre calculé. Les entrées `Nkx..NFFT-1` restent à zéro. Ainsi `NFFT ≥ Nkx` n'ajoute aucun calcul LU — le nombre de résolutions spectrales reste exactement `Nkx`.

**Côté MATLAB** : passer une grille uniforme à un seul intervalle, de 0 à kmax_physique :
```matlab
Nkx   = 2048;                          % puissance de 2 recommandée
kx_list = linspace(0, kmax, Nkx);
source.Nkx1 = Nkx; source.Nkx2 = 0; source.Nkx3 = 0;
[ux, uz] = gsm_mex(..., kx_list, ..., 'do_fft', true);
```

Cette grille remplace `kx_list` dans l'appel à `make_ustar_everywhere`. `sigma_kx` n'est plus étendue — elle garde la taille `Nkx` exacte.

### Intégration par IFFT symétrique (`fft_integrate_z`)

La TF inverse sur kx ≥ 0 se réduit à une transformée cosinus ou sinus selon la parité de la composante :

| Composante | Parité en kx |
|---|---|
| PSVz : ux | impaire → sin |
| PSVz : uz | paire → cos |
| PSVx : ux | paire → cos |
| PSVx : uz | impaire → sin |

`fft_integrate_z` construit un buffer symétrisé de taille `M = 2*NFFT` :
- Extension paire   : `buf[M-n] = +F[n]`
- Extension impaire : `buf[M-n] = -F[n]`

puis appelle `ifft_inplace`. La grille spatiale de sortie est $x_m = m \cdot \pi / (N_{FFT} \cdot dk_x)$.

Cette fonction est appelée **une seule fois par profondeur z** (lambda `compute_fft_buffers` dans `make_ustar_everywhere`), avant la boucle sur x.

### IFFT auto-contenue (`ifft_inplace`)

IDFT radix-2 Cooley-Tukey, in-place, en C++ pur, sans dépendance externe :
- Permutation bit-reverse standard
- Papillons avec facteur de torsion $e^{+2\pi i / \text{len}}$ (convention BACKWARD, sans normalisation par N)

Remplace un appel à `mwfftw3` qui causait des crashes MATLAB par corruption du singleton FFTW global de MATLAB lors du déchargement du MEX.

### Interpolation spatiale (branche `integrate_and_store`)

Les buffers `G_ux_fft` / `G_uz_fft` (taille M, un par z) sont lus par interpolation linéaire :

```
xi      = |x - xs|
m_exact = xi / dx_fft_spat
m0      = floor(m_exact)
t       = m_exact - m0
G_i     = (1-t)*G[m0] + t*G[m0+1]
```

Le signe des composantes impaires est appliqué après interpolation selon `x < xs` ou `x ≥ xs`.

### Limitations

**La grille kx doit être uniforme.** La relation $x_m = m \cdot \pi / (N_{FFT} \cdot dk_x)$ n'est valide que si tous les pas de `kx_list` sont identiques. Avec la grille 3-zones (pas variable), le résultat spatial serait faux. C'est la responsabilité de MATLAB de fournir une grille uniforme quand `do_fft=true`.

**Ce n'est pas le bottleneck en mode cache chaud.** La résolution SparseLU (Nkx systèmes, cache froid) domine à froid. En cache chaud (L1+L2+L3 valides), c'est la boucle `integrate_and_store` sur ix qui domine — la FFT remplace cette boucle O(Nkx×Nx) par une IFFT O(NFFT·log NFFT) + interpolation O(Nx), ce qui apporte un gain réel pour Nx grand.

---

## Optimisations possibles supplémentaires (non implémentées)

### Mode "batch xs" — passer xs_list entière en un seul appel MEX

**Problème actuel** : `makeUbmPSV` et `GreenPropagPSV` font N_D (ou N_I) appels MEX séparés,
chacun avec le coût fixe du parsing des arguments + copie de `kx_list` (~28 Ko) et `sigma_kx`
(~224 Ko). Avec le cache chaud (L1+L2+L3 valides), chaque appel ne fait que l'intégration de
Fourier (~0.1–1 ms) — l'overhead MEX devient alors une fraction non négligeable.

**Solution** : ajouter un paramètre `'xs_list'` à `gsm_mex` pour passer un vecteur de positions x
sources en un seul appel. Le C++ bouclerait sur les xs en interne, sans repasser par MATLAB entre
chaque xs. Bénéfices :
- Overhead MEX divisé par N_D (un seul parsing/copie)
- Cache L1+L2+L3 natif sans logique MATLAB (`use_cache`/`reset_cache` inutiles)
- Sorties : tensor 3D `ux[ix_obs][iz_obs][i_src]` ou équivalent

**Quand implémenter** : si le profiling montre que l'overhead MEX représente >10% du temps
total, ce qui arrive typiquement pour N_D > 200 avec cache chaud.

### Stocker la décomposition LU séparément du solve (niveau 1.5)

**Problème** : quand seul `sx`/`sz` change (transition passe 1 → passe 2), le niveau 2 est
invalide → Nkx SparseLU refaites. Or la matrice T_global ne dépend pas de `sx`/`sz`
(elle ne dépend que de la géométrie et de `kx`) — seul le vecteur source σ change.

**Solution** : stocker la factorisation LU dans le cache niveau 1 (après `precomputed`).
Lors d'un changement de `sx`/`sz` avec même géométrie : faire uniquement le **solve**
(`L·U·x = σ_nouveau`) sans refactoriser. Coût : O(N²) au lieu de O(N³) par kx.

**Gain théorique** : facteur ~10–50 sur le coût de la transition passe 1 → passe 2 dans
`makeUbmPSV` et `GreenPropagPSV`. Nécessite de modifier `make_ubar_interfaces` pour séparer
factorisation et solve, et d'ajouter `SparseLU<SparseMatrix<complex_d>> lu_cached` dans `GsmCache`.

### Parallélisation OpenMP de l'intégration de Fourier (bottleneck réel)

**Mesure** : avec Nkx=1503 et 101 points x (z=0 fixe), un appel chaud (L1+L2+L3 valides) coûte
~48.5 ms — dont ~48 ms d'intégration de Fourier (101 appels `integrate_and_store`). Le cache
ne sauve que ~3.8 ms (LU évités, 7% du total). L'overhead MEX pur est < 0.1%.

**Bottleneck** : la boucle sur `ix` dans `make_ustar_everywhere` (mode `mesh=true`) :
```cpp
for (int ix = 0; ix < Nx; ++ix) {
    integrate_and_store(x_list[ix], ix, iz);   // ~0.48 ms × Nx
}
```
Chaque appel est indépendant (pas de dépendance de données entre les ix).

**Solution** : ajouter `#pragma omp parallel for` sur cette boucle :
```cpp
#pragma omp parallel for schedule(static)
for (int ix = 0; ix < Nx; ++ix) {
    integrate_and_store(x_list[ix], ix, iz);
}
```
Ajouter `-fopenmp` (GCC/Clang) ou `/openmp` (MSVC) à la compilation dans `build_mex.m`.

**Gain théorique** : ×N_cœurs sur le coût d'intégration — avec 4 cœurs, ~48 ms → ~12 ms par appel.
S'applique aussi à la boucle `ix` en mode `mesh=false` (si plusieurs points partagent le même z).

**Priorité** : haute — c'est le vrai bottleneck d'après le profiling (mode cache chaud).

---

-- CE QUI A DEJA ETE FAIT ---
Calcul du champ de déplacement (ux, uz) dans un milieu élastique multicouches par la méthode GSM, compilé en MEX pour MATLAB.

---

## Fichiers du projet

| Fichier | Rôle |
|---|---|
| `gsm_mex.cpp` | Point d'entrée MEX. Lit les structs MATLAB, appelle `gsm_compute`, renvoie les résultats. Contient le cache inter-appels `cache_`. |
| `gsm_solver.h` | Définit `GsmInputs`, `GsmOutputs`, `GsmCache` et déclare `gsm_compute()`. Pas de dépendance Eigen ni MEX. |
| `gsm_solver.cpp` | Cœur du calcul : layer splitting, cache 3 niveaux, résolution du système, intégration de Fourier. |
| `aux_fonctions.h/.cpp` | Fonctions auxiliaires : construction des matrices (M, N, DN_inv), assemblage T_global, intégration Simpson, transformées de Fourier inverses. |
| `MecaConstantes.h/.cpp` | Classe regroupant les constantes mécaniques d'une couche (λ, μ, ks, kp, etc.) + propriétés dynamiques (dn_up, dn_dwn, w_n). |
| `build_mex.m` | Script de compilation en 4 étapes. Supporte le mode `fast` (ne recompile que `gsm_solver` + liens). |
| `test_gsm.m` | Script de test MATLAB avec 3 intervalles kx. |

---

## Appel depuis MATLAB

```matlab
% Mode grille (défaut) : x_list × z_list forment une grille rectangulaire
[ux_star, uz_star] = gsm_mex(materiaux, source, kx_list, x_list, z_list)

% Mode paires : chaque (x_list(i), z_list(i)) est un point arbitraire indépendant
[ux_star, uz_star] = gsm_mex(materiaux, source, kx_list, x_list, z_list, 'mesh', false)

% Réinitialisation complète du cache inter-appels
[ux_star, uz_star] = gsm_mex(materiaux, source, kx_list, x_list, z_list, 'reset_cache', true)
```

### Argument `materiaux` (struct)

| Champ | Type | Description |
|---|---|---|
| `cs` | complex vector (nb_couches × 1) | Vitesse S par couche |
| `cp` | complex vector (nb_couches × 1) | Vitesse P par couche |
| `rho` | double vector (nb_couches × 1) | Densité par couche |
| `d_list` | double vector (nb_couches × 1) | Position z des interfaces (0 = surface, négatif vers le bas) |

### Argument `source` (struct)

| Champ | Type | Description |
|---|---|---|
| `freq` | double | Fréquence [Hz] |
| `sx` | double | Composante x du tenseur source (0 pour PSVz) |
| `sz` | double | Composante z du tenseur source (0 pour PSVx) |
| `xs` | double | Position x de la source |
| `zs` | double | Position z de la source |
| `Nkx1` | int | Nombre de points kx dans l'intervalle 1 |
| `Nkx2` | int | Nombre de points kx dans l'intervalle 2 |
| `Nkx3` | int | Nombre de points kx dans l'intervalle 3 |

### Arguments directs

| Argument | Type | Description |
|---|---|---|
| `kx_list` | double vector (Nkx1+Nkx2+Nkx3 × 1) | Nombres d'onde horizontaux (3 intervalles concaténés) |
| `x_list` | double vector (Nx × 1) | Positions x d'observation |
| `z_list` | double vector | Positions z d'observation |

### Paramètres optionnels (paires clé/valeur après z_list)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `'mesh'` | logical | `true` | Mode de calcul des points d'observation (voir ci-dessous) |
| `'sigma_kx'` | complex matrix | `[]` | Vecteur source spectral personnalisé (taille 2·N × Nkx) |
| `'reset_cache'` | logical | `false` | Vide le cache inter-appels avant le calcul (voir section Cache) |

### Sorties selon le mode `mesh`

| `mesh` | Taille ux_star / uz_star | Description |
|---|---|---|
| `true` (défaut) | Nx × Nz complexe | Grille rectangulaire : tous les couples (x_list(i), z_list(j)) |
| `false` | 1 × N complexe (vecteur ligne) | Paires arbitraires : point i = (x_list(i), z_list(i)) |

---

## Cache inter-appels

### Principe

Le MEX maintient un objet `GsmCache cache_` **persistant** entre deux appels MATLAB consécutifs. Il est stocké comme membre privé de `MexFunction` — il vit tant que le MEX est chargé et est libéré automatiquement par `clear gsm_mex`. Il n'y a **aucune copie** de données à travers la frontière MEX.

Trois niveaux hiérarchiques : invalider le niveau N invalide automatiquement N+1 et N+2.

### Niveau 1 — `precomputed` (racines complexes + exponentielles aux interfaces)

**Clés** : `freq`, `kx_list`, `d_list` (post-splitting), `cs_list`, `cp_list`, `rho_list`

**Contenu** : tableau `precomputed[couche][ikx][0..11]` — kpz, ksz, a1–a4, gp, gs, qp, qs, γp, γs

**Invalidé si** : fréquence, grille kx, matériaux ou géométrie des couches change (y compris si `zs` change et provoque un splitting différent).

**Gain** : évite Nkx × N_couches racines carrées complexes et exponentielles.

### Niveau 2 — `An_vector_list` (coefficients de modes, solution du système)

**Clés** : niveau 1 valide + `sx`, `sz`, `zs`

**Contenu** : tableau `An_vector_list[couche][4][ikx]` — coefficients C1–C4 par couche et kx

**Invalidé si** : niveau 1 invalide, ou `sx`/`sz`/`zs` change. Invalidé systématiquement si `sigma_kx` est fourni par l'utilisateur (cas personnalisé non géré par le cache).

**Gain** : évite Nkx décompositions SparseLU — c'est le bottleneck principal.

### Niveau 3 — `ux/uz_barstar_all_z` (spectres par profondeur)

**Clés** : niveau 2 valide + `z_list`

**Contenu** : `ux_barstar_all_z[k][ikx]` et `uz_barstar_all_z[k][ikx]` — un spectre complet par profondeur unique

**Invalidé si** : niveaux 1 ou 2 invalides, ou `z_list` change.

**Gain** : évite Nz × Nkx calculs d'exponentielles relatives dans `make_u_barstar_multicouches`.

### Tableau de synthèse — ce qui est refait selon ce qui change

| Paramètre modifié | Niveau 1 | Niveau 2 | Niveau 3 | Intégration Fourier |
|---|---|---|---|---|
| `xs` seulement | ✓ cache | ✓ cache | ✓ cache | recalculé |
| `z_list` change | ✓ cache | ✓ cache | recalculé | recalculé |
| `sx` ou `sz` change | ✓ cache | recalculé | recalculé | recalculé |
| `zs` change | recalculé | recalculé | recalculé | recalculé |
| `freq` change | recalculé | recalculé | recalculé | recalculé |

> **Cas d'usage optimal** : appels successifs avec le même milieu, même source, même grille z — seul `xs` change entre deux appels. C'est exactement le cas de `makeUbmPSV` (boucle sur xs_list avec zs=0 fixe). Gain typique : ×5–20 sur le temps total.

### Utilisation de `reset_cache`

```matlab
% Forcer un recalcul complet (utile si le milieu a changé entre deux sessions)
[ux, uz] = gsm_mex(mat, src, kx_list, x_list, z_list, 'reset_cache', true);

% Libérer la mémoire du cache (équivalent)
clear gsm_mex
```

`reset_cache` est rarement nécessaire : les clés de validation détectent automatiquement tout changement. Il peut être utile pour forcer une mesure de performance "à froid" ou après avoir modifié le milieu sans changer les valeurs numériques des clés.

### Stratégie d'appel côté MATLAB pour maximiser le cache

#### `makeUbmPSV` — boucle sur `xs_list` avec `zs = 0` fixe

Le gain maximal est obtenu en faisant **deux passes séparées** (tous les `sx=1` d'abord, puis tous les `sx=0`) plutôt qu'une alternance `sx=1`/`sx=0` pour chaque i :

```matlab
% ✗ MAUVAIS : alterne sx=1/sx=0 → invalide L2 à chaque itération
for i = 1:N_D
    [UBMxx, UBMxz] = gsm_mex(..., 'sx',1,'sz',0,...);   % cold L2
    [UBMzx, UBMzz] = gsm_mex(..., 'sx',0,'sz',1,...);   % cold L2
end
% Total : 2*N_D appels froids

% ✓ BON : 2 passes → L1+L2+L3 valides dans chaque passe, seul xs change
for i = 1:N_D
    [UBMxx, UBMxz] = gsm_mex(..., xs_list(i), ..., 'sx',1,'sz',0,...);
end
for i = 1:N_D
    [UBMzx, UBMzz] = gsm_mex(..., xs_list(i), ..., 'sx',0,'sz',1,...);
end
% Total : 2 appels froids + 2*(N_D-1) appels chauds
```

#### `GreenPropagPSV` — boucle sur `(xs, zs) = (X(i), Z(i))`

`zs` varie → L1 est invalide entre deux points de z différent. Mais pour un même point source, passer de `sx=1` à `sx=0` ne change pas `zs` → L1+L2+L3 valides :

```matlab
% ✓ BON : pour chaque source i, appeler sx=1 puis immédiatement sx=0
for i = 1:N_I
    [Gxx, Gxz] = gsm_mex(..., X(i), Z(i), ..., 'sx',1,'sz',0,...);  % cold L1+L2
    [Gzx, Gzz] = gsm_mex(..., X(i), Z(i), ..., 'sx',0,'sz',1,...);  % hit L1+L2+L3
end
% Gain : N_I appels SparseLU économisés (moitié des appels)
```

Si plusieurs points source partagent le même `Z(i)` (ex. grille régulière), les grouper par z croissant permet en plus de réutiliser L1 entre points du même groupe.

---

## Mode `mesh=true` vs `mesh=false`

### `mesh=true` — grille (défaut)

`x_list` (Nx valeurs) et `z_list` (Nz valeurs) définissent un maillage rectangulaire complet de Nx×Nz points. Le calcul est optimisé : pour chaque profondeur z, le spectre `u_barstar(kx, z)` est calculé **une seule fois** et réutilisé pour tous les Nx points x. C'est le mode le plus efficace.

```matlab
x_list = linspace(-50, 50, 200);   % 200 valeurs x
z_list = linspace(-30, 0, 100);    % 100 valeurs z
[ux, uz] = gsm_mex(..., x_list, z_list);
% ux est 200×100
```

### `mesh=false` — paires arbitraires

`x_list(i)` et `z_list(i)` forment une paire de coordonnées indépendante. Utile pour calculer le champ sur un contour, un profil courbe, ou un masque arbitraire (ex : disque). La sortie est un vecteur ligne 1×N dans l'ordre original des paires.

```matlab
% Exemple : points sur un cercle
theta = linspace(0, 2*pi, 500);
x_list = R * cos(theta);
z_list = -R * sin(theta);  % z négatif = profondeur
[ux, uz] = gsm_mex(..., x_list, z_list, 'mesh', false);
% ux est 1×500
```

**Cas d'usage typique — masque sur grille régulière** : si tu as une grille rectangulaire et que tu veux ignorer les points hors d'un domaine (disque, ellipse...), construis x_list/z_list à partir des indices du masque MATLAB et utilise `mesh=false`. Tu évites le calcul des points hors domaine tout en bénéficiant de l'optimisation interne (voir section pipeline).

```matlab
[X, Z] = meshgrid(x_vec, z_vec);
mask = (X.^2 + Z.^2) <= R^2;          % masque disque
x_list = X(mask)';
z_list = Z(mask)';
[ux, uz] = gsm_mex(..., x_list, z_list, 'mesh', false);
```

### Performances comparées

| Scénario | appels `make_u_barstar` | appels `integrate_and_store` |
|---|---|---|
| `mesh=true`, rectangle Nx×Nz | Nz | Nx×Nz |
| `mesh=false`, paires toutes distinctes | N\_points | N\_points |
| `mesh=false`, masque sur grille (z répétés) | Nz (grâce à l'optim) | N\_points |

---

## Pipeline de calcul — ordre d'appel des fonctions

L'appel MATLAB arrive dans `gsm_mex.cpp` → `MexFunction::operator()` → `gsm_compute()` → fonctions internes.

### 1. `MexFunction::operator()` — `gsm_mex.cpp`

**Rôle** : Passerelle MATLAB ↔ C++.

- Lit les structs MATLAB via `readDoubleScalar`, `readComplexVector`, `readDoubleVector`, `readDoubleArray`
- Parse les paramètres optionnels à partir de l'argument 5 : `'mesh'` (bool, défaut `true`), `'sigma_kx'` (matrice complexe, optionnelle) et `'reset_cache'` (bool, défaut `false`)
- Si `reset_cache=true` : réinitialise `cache_` à un état vide (`GsmCache{}`) avant le calcul
- Vérifie la cohérence des tailles si `mesh=false` : x_list et z_list doivent avoir la même longueur
- Remplit un `GsmInputs` (dont le champ `bool mesh`)
- Appelle `gsm_compute(in, out, &cache_)` dans un `try/catch` (les exceptions C++ sont converties en `error()` MATLAB)
- Convertit `GsmOutputs` en matrices MATLAB complexes :
  - `mesh=true` → matrice Nx×Nz
  - `mesh=false` → vecteur ligne 1×N

### 2. `gsm_compute(in, out, cache)` — `gsm_solver.cpp`

**Rôle** : Point d'entrée du solveur. Orchestre les étapes et gère les vérifications de cache.

**Entrées** : `const GsmInputs& in`, `GsmCache* cache` (nullptr = pas de cache)
**Sorties** : `GsmOutputs& out` (ux_star, uz_star remplis)

#### Étape 0 — Layer splitting (source enfouie)

Si `zs` ne coïncide pas avec une interface existante, la couche contenant la source est subdivisée en créant une nouvelle interface à `zs`. Les copies locales `d_list`, `cs_list`, `cp_list`, `rho_list` sont modifiées ; `N` est incrémenté. Les deux sous-couches héritent des mêmes propriétés matériaux.

#### Vérification cache niveau 1

Compare `freq`, `kx_list`, `d_list` (post-splitting), `cs_list`, `cp_list`, `rho_list` avec les clés stockées. Si une différence est détectée : `valid_geo = valid_source = valid_field = false`, les nouvelles clés sont stockées.

#### Vérification cache niveau 2

Si `sigma_kx` est fourni par l'utilisateur → `valid_source = false` systématiquement. Sinon, compare `sx`, `sz`, `zs` avec les clés stockées. Invalide `valid_source` et `valid_field` si différence.

#### Vérification cache niveau 3

Compare `z_list` avec `z_list_cached`. Invalide `valid_field` si différence. La clé `z_list_cached` est **toujours** mise à jour même en cas de miss de niveau 1 ou 2.

#### Étape 1 — Construction de `mc_list`

Pour chaque couche `n` (de 0 à N-1) :
- Crée un `MecaConstantes(rho, cs, cp, omega, sx, 0, sz, xs, zs)`
- Ajoute les propriétés dynamiques :
  - `dn_up` : position z de l'interface supérieure
  - `dn_dwn` : position z de l'interface inférieure (couches finies uniquement)
  - `w_n` : épaisseur = `dn_up - dn_dwn` (couches finies uniquement)

#### Étape 2 — Recherche de la couche source

Parcourt `mc_list` pour trouver dans quelle couche se situe `zs`. Résultat : `source_layer` (utilisé comme `i_interface` dans la suite).

#### Étape 3 — Calcul de kmax / kmin

Informatif (la construction de kx_list est faite côté MATLAB).

#### Étape 4 — Initialisation des sorties

- `mesh=true` : alloue `out.ux_star` et `out.uz_star` de taille Nx × Nz
- `mesh=false` : alloue de taille Nx × 1

#### Étape 5 — Appel à `make_ustar_everywhere`

Copie locale de kx_list, x_list, z_list puis appel avec `cache`.

---

### 3. `make_ustar_everywhere(...)` — `gsm_solver.cpp` (static)

**Rôle** : Calcul complet du champ de déplacement en tous les points (x, z). Gère les 3 niveaux de cache.

**Entrées** :

| Paramètre | Type | Description |
|---|---|---|
| `i_interface` | int | Indice de la couche source |
| `x_list` | vector\<double\> | Positions x d'observation |
| `z_list` | vector\<double\> | Positions z d'observation |
| `kx_list` | vector\<double\> | Nombres d'onde (3 intervalles concaténés) |
| `mc_list` | vector\<MecaConstantes\> | Propriétés de chaque couche |
| `Nkx1, Nkx2, Nkx3` | int | Tailles des 3 intervalles |
| `mesh` | bool | Mode grille (true) ou paires (false) |
| `cache` | GsmCache* | Pointeur vers le cache (nullptr = pas de cache) |

**Sorties** : `ux_star[ix][iz]`, `uz_star[ix][iz]` (remplis sur place)

**Déroulement** :

1. **Calcul des pas** : `dkx`, `dkx2`, `dkx3` pour chaque intervalle

2. **Niveau 1 — `precomputed[couche][ikx][0..11]`** :
   - Si `cache->valid_geo` : la référence pointe directement vers `cache->precomputed`, la boucle de construction est sautée entièrement.
   - Sinon : construction (racines carrées complexes, exponentielles aux interfaces), stockage dans `cache->precomputed`, puis `cache->valid_geo = true`.
   - Si `cache == nullptr` : variable locale utilisée, comportement identique à l'ancienne version.

   | Indice | Valeur | Description |
   |---|---|---|
   | 0 | kpz | Nombre d'onde vertical P (imag positive forcée) |
   | 1 | ksz | Nombre d'onde vertical S (imag positive forcée) |
   | 2 | a1 | -(λ·kx² + (λ+2μ)·kpz²) |
   | 3 | a2 | 2μ·kx·ksz |
   | 4 | a3 | 2μ·kx·kpz |
   | 5 | a4 | μ·(ksz² - kx²) |
   | 6 | gp | exp(-i·kpz·dn_up) |
   | 7 | gs | exp(-i·ksz·dn_up) |
   | 8 | qp | exp(-i·kpz·dn_dwn) — 0 pour le half-space |
   | 9 | qs | exp(-i·ksz·dn_dwn) — 0 pour le half-space |
   | 10 | γp | exp(i·kpz·w_n) — 0 pour le half-space |
   | 11 | γs | exp(i·ksz·w_n) — 0 pour le half-space |

3. **Niveau 2 — `An_vector_list`** :
   - Si `cache->valid_source` : la référence pointe vers `cache->An_vector_list`, `make_ubar_interfaces` est sautée entièrement (les Nkx SparseLU ne sont pas refaites).
   - Sinon : allocation, appel à `make_ubar_interfaces`, puis `cache->valid_source = true`.

4. **Deux lambdas utilitaires** (définis une fois, réutilisés dans les deux modes) :
   - `update_couche(z)` : met à jour `couche_z` de façon incrémentale (les z sont traités du plus profond vers la surface).
   - `integrate_and_store(x, out_ix, out_iz)` : intégration de Fourier inverse sur 3 intervalles Simpson à partir du spectre `ux/uz_barstar_z` courant. Contient le branchement PSVz/PSVx écrit **une seule fois**.

5. **Niveau 3 — spectres par profondeur** (dans la boucle z) :

   **`mesh=true` (grille)** :
   - Hit : `ux/uz_barstar_z` chargé depuis `cache->ux/uz_barstar_all_z[k]`, `make_u_barstar_multicouches` sautée.
   - Miss : calcul, stockage dans `cache->ux/uz_barstar_all_z[k]`, puis `valid_field = true` après la boucle.

   **`mesh=false` (paires, avec grouping-by-z)** :
   - Hit : identique, parcours par groupe avec `group_idx`.
   - Miss : `push_back` par groupe unique, puis `valid_field = true`.

   ```
   [mesh=true, miss L3]
   pour k = 0 to Nz-1 :           ← ordre trié par z décroissant
       iz = sorted_iz[k]
       z  = z_list[iz]
       update_couche(z)
       make_u_barstar_multicouches(z)    ← 1 appel par profondeur z
       cache->ux_barstar_all_z[k] = ux_barstar_z
       pour ix = 0 to Nx-1 :
           integrate_and_store(x_list[ix], ix, iz)
   valid_field = true

   [mesh=true, hit L3]
   pour k = 0 to Nz-1 :
       iz = sorted_iz[k]
       ux_barstar_z = cache->ux_barstar_all_z[k]   ← chargement direct
       pour ix = 0 to Nx-1 :
           integrate_and_store(x_list[ix], ix, iz)
   ```

---

### 4. `make_ubar_interfaces(...)` — `gsm_solver.cpp` (static)

**Rôle** : Pour chaque kx, assemble le système global de raideur et le résout pour obtenir les déplacements aux interfaces et les coefficients An.

**Entrées** :

| Paramètre | Description |
|---|---|
| `mc_list` | Propriétés des couches |
| `kx_list` | Nombres d'onde |
| `precomputed` | Cache pré-calculé |
| `i_interface` | Couche de la source |

**Sorties** :

| Paramètre | Taille | Description |
|---|---|---|
| `u_bar_interfaces` | (2·nb_couches) × Nkx | Déplacements (ux, uz) à chaque interface pour chaque kx |
| `An_vector_list` | nb_couches × 4 × Nkx | Coefficients An par couche (A⁻, B⁻, A⁺, B⁺ pour couches finies ; A⁻, B⁻, 0, 0 pour le half-space) |

**Déroulement** (pour chaque kx) :
1. Construit les matrices de raideur 4×4 (Tn = Mn·Nn⁻¹) via `make_44_matrices_opt` → couches finies
2. Construit la matrice 2×2 du half-space via `make_22_matrices_opt`
3. Assemble T_global (sparse) via `make_T_global`
4. Construit le vecteur source σ (sx à la ligne 2·i_interface, i·sz à la ligne suivante)
5. Résout T_global · u = σ par SparseLU. Lance une exception si échec.
6. Extrait les déplacements aux interfaces
7. Calcule An = DN_inv · u pour chaque couche

---

### 5. `make_u_barstar_multicouches(...)` — `gsm_solver.cpp` (static)

**Rôle** : Calcule u(ω, kx, z) pour un z donné et tous les kx, à partir des coefficients An.

**Entrées** :

| Paramètre | Description |
|---|---|
| `kx_list` | Nombres d'onde |
| `z` | Profondeur du point d'observation |
| `couche_z` | Indice de la couche contenant z |
| `An_vector_list` | Coefficients An (sortie de `make_ubar_interfaces`) |
| `mc_list` | Propriétés des couches |
| `precomputed` | Cache (pour kpz, ksz) |

**Sorties** : `ux_barstar[ikx]`, `uz_barstar[ikx]` pour chaque kx

**Formules** (exponentielles relatives, anti-overflow) :
- **Couche finie** (4 coefficients) :
  - ux = i·kx·gp_rel·C1 + i·ksz·gs_rel·C2 + i·kx·gpm_rel·C3 - i·ksz·gsm_rel·C4
  - uz = -i·kpz·gp_rel·C1 + i·kx·gs_rel·C2 + i·kpz·gpm_rel·C3 + i·kx·gsm_rel·C4
  - avec `gp_rel = exp(-i·kpz·(z - dn_up))`, `gpm_rel = exp(+i·kpz·(z - dn_dwn))` — module ≤ 1 car `dn_dwn ≤ z ≤ dn_up`
- **Half-space** (2 coefficients, ondes descendantes uniquement) :
  - ux = i·kx·gp_rel·C1 + i·ksz·gs_rel·C2
  - uz = -i·kpz·gp_rel·C1 + i·kx·gs_rel·C2

Les exponentielles d'interface (gp, gs aux positions absolues dn_up, dn_dwn) sont dans le cache `precomputed` et ne sont **pas** recalculées ici. Seules les 4 exponentielles relatives à z (qui dépendent du point d'observation) sont calculées à chaque appel.

---

### 6. `assure_imag_positive(z)` — `gsm_solver.cpp` (static)

**Rôle** : Force la partie imaginaire d'un nombre complexe à être positive (convention ondes évanescentes).

**Entrée** : `complex z`
**Sortie** : `z` si imag(z) ≥ 0, sinon `-z`

---

## Fonctions auxiliaires (`aux_fonctions.cpp`)

### Matrices de raideur

| Fonction | Entrées | Sortie | Rôle |
|---|---|---|---|
| `make_44_matrices_opt` | kx, mc, precomputed, ind_kx, couche | M4, N4, DN_inv (4×4) | Matrices de raideur d'une couche finie (version cache) |
| `make_22_matrices_opt` | kx, ind_kx, nb_hs, precomputed | M2, N2, DN_inv (2×2) | Matrices de raideur du half-space (version cache) |
| `make_44_matrices` | kx, mc | M4, N4, DN_inv | Version sans cache |
| `make_22_matrices` | kx, mc | M2, N2, DN_inv | Version sans cache |

### Assemblage

| Fonction | Entrées | Sortie | Rôle |
|---|---|---|---|
| `make_T_global` | Tn_list (4×4 par couche), T_hs (2×2) | SparseMatrix T_global | Assemble la matrice de raideur globale (sparse, bloc-tridiagonale) |

### Intégration

| Fonction | Entrées | Sortie | Rôle |
|---|---|---|---|
| `complex_simpson_vector_start_end` | h, f_xi, start, end | complex | Simpson sur un sous-intervalle [start, end) |
| `complex_simpson_vector` | h, f_xi | complex | Simpson sur le vecteur entier |
| `Fourier_inverse_complex_vector_even` | kx, x, xs, f_vect | vector\<complex\> | TF inverse (fonction paire) : f(kx)·cos(kx·(x-xs)) |
| `Fourier_inverse_complex_vector_odd` | kx, x, xs, f_vect | vector\<complex\> | TF inverse (fonction impaire) : f(kx)·sin(kx·(x-xs)) |

---

## MecaConstantes

Créé avec `MecaConstantes(rho, cs, cp, omega, Fx, Fy, Fz, xs, zs)`.

Le constructeur calcule automatiquement :
- `ks = omega/cs`, `kp = omega/cp`
- `mu = rho·cs²`, `lambda = rho·cp² - 2μ`
- `E`, `nu`

Propriétés dynamiques ajoutées après construction via `addProp()` :
- `"dn_up"` (double) : z de l'interface supérieure
- `"dn_dwn"` (double) : z de l'interface inférieure
- `"w_n"` (double) : épaisseur de la couche

Accès : `std::any_cast<double>(mc.dynProps.at("dn_up"))`

---

## Compilation

```matlab
cd('C:\Users\melka\Documents\C++\GSM_MEX\Troisieme_test')
build_mex          % compilation complète (4 étapes)
build_mex(true)    % mode rapide : ne recompile que gsm_solver + liens
```

Étapes :
1. `aux_fonctions.cpp` → `build/aux_fonctions.obj`
2. `gsm_solver.cpp` → `build/gsm_solver.obj`
3. `MecaConstantes.cpp` → `build/MecaConstantes.obj`
4. `gsm_mex.cpp` + `.obj` → `gsm_mex.mexw64`

Le mode `fast` saute les étapes 1 et 3 (fichiers stables).

---

## Gestion des erreurs

- Les échecs de décomposition LU dans `make_ubar_interfaces` lèvent une `std::runtime_error`
- `gsm_mex.cpp` encadre `gsm_compute` dans un `try/catch` et convertit l'exception en `error()` MATLAB
- En mode `mesh=false`, `gsm_mex.cpp` vérifie que x_list et z_list ont la même longueur avant d'appeler le solveur
- Les erreurs apparaissent normalement dans la console MATLAB (pas de crash silencieux)

---

## MEX de construction de G et UBM — `mex_G_and_Ubm_PSV_rho`

### Motivation

`GreenPropagPSV.m` et `makeUbmPSV.m` effectuent chacune `2×N` appels à `gsm_mex` (N = N_I ou N_D). Même avec le cache chaud, chaque traversée MEX paie le coût fixe de parsing des arguments + copie de `kx_list` et `sigma_kx`. Ce MEX réduit l'ensemble à **une seule traversée**, le cache C++ étant partagé sur les 4 boucles internes (G passe 1, G passe 2, UBM passe 1, UBM passe 2).

Gain supplémentaire : dans les boucles UBM (`zs=0` fixe, `z_list=Zi` fixe), le **cache L3** (`barstar_all_z`) calculé pendant G reste valide pour UBM — ce qui n'est pas possible avec deux appels MEX séparés.

### Fichiers

| Fichier | Rôle |
|---|---|
| `mex_G_and_Ubm_PSV_rho.cpp` | Point d'entrée MEX. Construit G et UBM en C++ avec un `GsmCache` local partagé. |
| `build_mex_G_and_Ubm_PSV_rho.m` | Script de compilation dédié (4 étapes, mode fast supporté). |
| `../Serie_Born_meca/GreenPropagPSV_v2.m` | Wrapper MATLAB : construit `kx_list` puis appelle le MEX avec `xs_list=[]`. |
| `../Serie_Born_meca/makeUbmPSV_v2.m` | Wrapper MATLAB : construit `kx_list` puis appelle le MEX avec `xs_list` fourni. |
| `../Serie_Born_meca/test_G_and_Ubm_v2.m` | Test de validation numérique + benchmark de temps. |

### Appel depuis MATLAB

```matlab
% Construction simultanée de G et UBM
[G, UBM] = mex_G_and_Ubm_PSV_rho(xs_list, Xi, Zi, materiaux, freq, kx_list, ...
                                   Nkx1, Nkx2, Nkx3)

% Options nommées (paires après Nkx3)
% 'a'      : double, défaut 0.0 — demi-largeur source (0 = ponctuelle)
% 'do_fft' : logical, défaut false — intégration FFT

% Construire G uniquement (xs_list vide → UBM est 0×0)
[G, ~] = mex_G_and_Ubm_PSV_rho([], Xi, Zi, materiaux, freq, kx_list, Nkx1, Nkx2, Nkx3)
```

**Arguments positionnels :**

| Indice | Argument | Type | Description |
|---|---|---|---|
| 1 | `xs_list` | double 1×N_D (ou `[]`) | Positions x des détecteurs |
| 2 | `Xi` | double 1×N_I | Positions x des points d'inclusion |
| 3 | `Zi` | double 1×N_I | Positions z des points d'inclusion (**triés par Z croissant**) |
| 4 | `materiaux` | struct | Identique à `gsm_mex` (`.cs`, `.cp`, `.rho`, `.d_list`) |
| 5 | `freq` | double | Fréquence [Hz] |
| 6 | `kx_list` | double array | Vecteur des kx (construit par le wrapper MATLAB) |
| 7 | `Nkx1` | double→int | Nb points intervalle 1 |
| 8 | `Nkx2` | double→int | Nb points intervalle 2 |
| 9 | `Nkx3` | double→int | Nb points intervalle 3 |

**Sorties :**

| Sortie | Taille | Description |
|---|---|---|
| `G` | (2·N_I) × (2·N_I) complexe | Propagateur de Green — colonne 2j-1 : source sx au point j ; colonne 2j : source sz |
| `UBM` | (2·N_D) × (2·N_I) complexe | Propagateur détecteurs→inclusion — ligne 2i-1 : composante x ; ligne 2i : composante z |

### Utilisation des wrappers

```matlab
% Équivalent à GreenPropagPSV mais avec un seul appel MEX
G = GreenPropagPSV_v2(Xi, Zi, materiaux, 'freq', 40, 'Nkx1', 501, ...)

% Équivalent à makeUbmPSV mais avec un seul appel MEX
UBM = makeUbmPSV_v2(xs_list, Xi, Zi, materiaux, 'freq', 40, ...)

% Dans BornPSVrhonaive : construire G et UBM en un seul appel
[G, UBM] = mex_G_and_Ubm_PSV_rho(Xd, Xi, Zi, materiaux, freq, kx_loc, ...)
```

### Compilation

```matlab
cd('.../GSM_MEX/source_cpp')

% Compilation complète (1ère fois, ou après modification de aux_fonctions / MecaConstantes)
build_mex_G_and_Ubm_PSV_rho

% Mode rapide (après modification de mex_G_and_Ubm_PSV_rho.cpp ou gsm_solver.cpp uniquement)
build_mex_G_and_Ubm_PSV_rho(true)
```

Les `.obj` (`aux_fonctions`, `gsm_solver`, `MecaConstantes`) sont partagés avec `gsm_mex`. Si `build_mex` a été exécuté récemment, le mode fast suffit.

### Détail du cache partagé

Le `GsmCache` est **local à l'appel** `operator()` (non persistant entre deux appels MATLAB, contrairement à `gsm_mex`). L'ordre des boucles garantit la réutilisation maximale :

```
Cache froid → Passe G sx=1 : L1+L2+L3 calculés au 1er z-groupe, réutilisés dans le groupe
              Passe G sz=1 : L2 invalidé une seule fois (sx/sz change), L1+L3 valides
              Passe UBM sx=1 : L2 invalidé (sx change), L3 valide (z_list=Zi inchangé)
              Passe UBM sz=1 : L2 invalidé une fois, puis N_D-1 appels chauds
```

Pour `a=0` (défaut) : `sigma_kx` laissé vide → chemin natif `in.sx/in.sz` → cache L2 actif.
Pour `a≠0` : `sigma_kx` fourni explicitement → cache L2 désactivé (acceptable — le gain principal reste la réduction des traversées MEX).
