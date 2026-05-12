
addpath("C:\Users\melka\Desktop\experimental_reprise\fonctions") % ordi portable
addpath(genpath("C:\Users\Utilisateur\Desktop\Experimental\ScriptPropres")) % ordi fixe
%namebase = "C:\Users\melka\Desktop\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\transverse\";
namebase = "C:\Users\Utilisateur\Desktop\Experimental\experimental_reprise\MesManip\PMMA_reflexion_MHZ_sigmat_cst\transverse\";
name_c1 = namebase+"transverse_fc_0p8Mhz_c1.mat";%0.5 ok
name_c2 = namebase+"transverse_fc_0p8Mhz_c2.mat";
fc = 0.8e6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% On commence a récupérer une structure qui contient :
% freq : les fréquences associées 
% temps : le temps du signal
% emeteur.c1 et emeteur.c2 :  les signaux de l'emeteur sur les 2 calibres
%               d'enregistrement
% idem avec recepteur
% pics : pic.emeteur, .recepteur, .pic_concat
%        pic.emeteur : .c1 et .c2 pour les 2calibre
%               pic.emeteur.c1 : .pics valeur de la tension au niveau du
%               pic 
%                                 .pic_id indice correpondant dans la liste
%        pic_concat: concatenation des pics des deux calibres
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[output] = files2struct_2calibres(name_c1,name_c2,1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Verification de la fonction elle est ok
%%Verifions l output
% Verification de emeteur
% calibre 1 
% figure;
% plot(output.emeteur.c1)
% hold on;
% scatter(output.pics.emeteur.c1.pic_id,output.pics.emeteur.c1.pic)
% calibre 2 
% figure;
% plot(output.emeteur.c2)
% hold on;
% scatter(output.pics.emeteur.c2.pic_id,output.pics.emeteur.c2.pic)

% Verification de recepteur
% c1
% figure;
% plot(output.recepteur.c1)
% hold on;
% scatter(output.pics.recepteur.c1.pic_id,output.pics.recepteur.c1.pic)
%c2
% figure;
% plot(output.recepteur.c2)
% hold on;
% scatter(output.pics.recepteur.c2.pic_id,output.pics.recepteur.c2.pic)


%% Fenetrage rectangulaire
S = output.emeteur.c1;
pic_indexes = output.pics.emeteur.c1.pic_id;
[pulse_array] = fenetre_rect(S,pic_indexes,false);
%%
% pulse_array contient la liste des pulses a traiter
freq = output.freq;
e = 2e-2;
% option.fc = fc;
% option.tronq = true;
% option.delta_f = 0.1e6;
[data] = pulses2data(freq,pulse_array{2},pulse_array{3},e,tronq=true,fc=fc,delta_f=0.1e6);
%%
figure;
plot(data.freq,data.vg)