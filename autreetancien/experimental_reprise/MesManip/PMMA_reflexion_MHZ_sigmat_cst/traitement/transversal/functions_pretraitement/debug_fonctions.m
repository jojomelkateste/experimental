
addpath("C:\Users\melka\Desktop\experimental_reprise\fonctions")
namebase = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\transverse\";
name_c1 = namebase+"transverse_fc_0p5Mhz_c1.mat";
name_c2 = namebase+"transverse_fc_0p5Mhz_c2.mat";

[output] = signal2pics_2calibres(name_c1,name_c2,1,1);


%%
S = output.emeteur.c1;
[pulse_array] = fenetre_rect(S,pic_indexes,plot_on=true);