% Determinons la durée d'un pulse selon la frequence comparons 
% 
fc= 100e3;
f = linspace(fc/100,10*fc,1000); Nf = length(f);
% df = f(2)-f(1);
% dt = 1/(df*Nf);
% t = 0:dt:1/df/100;
t = linspace(0,100*10^-6,10000);
w = 2*pi*f;
alpha = pi*fc;
t0 = 0.2e-4;
beta = t0;
% RF = ricker_freq(w,alpha,beta);
% RT = ricker_temporel(t,alpha,beta);
% % plot du ricker
% figure
% subplot(1,2,1)
% plot(f,abs(RF))
% subplot(1,2,2)
% plot(t*10^6,(RT))
% 
% % plot de la gaussienne
% N_sigma = 3;
% sigmaf  = fc/N_sigma;
% sigmat = 1/2/pi/sigmaf;
% A = cos(2*pi*fc*(t-t0)).*exp(-(t-t0).^2/2/sigmat^2);
% figure;
% plot(t*10^6,(RT),DisplayName="Ricker",LineWidth=3)
% hold on
% plot(t*10^6,A,DisplayName="Gaussienne",LineWidth=3)
% xlabel("t en micro secondes")
% title("f = "+fc/10^3 + " kHz")
% legend;
% set(gca,fontsize=18)

%%  Trajet en configuration radargram
vp = 2800;
vs = 1400;
vr = 0.91*vs;
% 1er figure 
L = 35e-2;
delta_x = linspace(0,L);
% d pour trajet direct 
%   p pour onde p
%   R pour onde R
t_d_p = delta_x/vp; % trajet direct onde P.
t_d_r = delta_x/vr; % trajet direct onde R
t_d_s = delta_x/vs; % trajet direct onde S
% r1d reflexion sur la meme ligne 
t_r1d_p  = L/vp+0*delta_x;
t_r1d_r  = L/vr+0*delta_x;
% reflexion au bord
t_rb_p = sqrt(delta_x.^2+L^2)/vp;
t_rb_r = sqrt(delta_x.^2+L^2)/vr;

%% Different plot pour répondre a différente questions
x_fill = [delta_x, fliplr(delta_x)]*1e2; % X avance puis revient à 0
%%%%%%%%%% PARAMETRE IMPORTANT DURE DU PULSE SELON LA FREQUENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if fc==100e3
    ecart = 24e-6;% duree du pulse pour f=100 kHz
else
    ecart = 11e-6;% si f= 200 kHz 
end
figure;
plot(delta_x*1e2,t_d_p,LineWidth=2,DisplayName="P direct");
% on rempli une zone pour materialiser la durée du pulse
y_fill = [(t_d_p + ecart), fliplr(t_d_p - ecart)]; % Y supérieur puis Y inférieur
hold on;
% Remplissage de la zone
fill(x_fill, y_fill, 'b', ...      % 'b' pour bleu
    'FaceAlpha', 0.3, ...          % Transparence (0 = invisible, 1 = opaque)
    'EdgeColor', 'none', ...
    'HandleVisibility', 'off');          % Supprime le contour du polygone
plot(delta_x*1e2,t_d_r,LineWidth=2,DisplayName="R direct");
% idem zone
y_fill = [(t_d_r + ecart), fliplr(t_d_r - ecart)]; % Y supérieur puis Y inférieur
% Remplissage de la zone
fill(x_fill, y_fill, 'r', ...      % 'b' pour bleu
    'FaceAlpha', 0.3, ...          % Transparence (0 = invisible, 1 = opaque)
    'EdgeColor', 'none', ...
    'HandleVisibility', 'off');          % Supprime le contour du polygone

plot(delta_x*1e2,t_d_s,LineWidth=2,DisplayName="S direct");
y_fill = [(t_d_s + ecart), fliplr(t_d_s - ecart)]; % Y supérieur puis Y inférieur
% Remplissage de la zone
fill(x_fill, y_fill, 'yellow', ...      % 'b' pour bleu
    'FaceAlpha', 0.3, ...          % Transparence (0 = invisible, 1 = opaque)
    'EdgeColor', 'none', ...
    'HandleVisibility', 'off');          % Supprime le contour du polygone

legend;
xlabel("delta x [cm]")
set(gca,fontsize=18)
title("Quel distance pour diférencier P de R")

%% Onde P VS onde P parasite

figure;
% deja l onde P direct 
plot(delta_x*1e2,t_d_p,LineWidth=2,DisplayName="P direct");
hold on;
% les ondes p 
% on rempli une zone pour materialiser la durée du pulse
y_fill = [(t_d_p + ecart), fliplr(t_d_p - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'b','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
% la reflexion au bords onde P
plot(delta_x*1e2,t_rb_p,LineWidth=2,DisplayName="P au bord");
y_fill = [(t_rb_p + ecart), fliplr(t_rb_p - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'r','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
% la reflexion 1D
plot(delta_x*1e2,t_r1d_p,LineWidth=2,DisplayName="P 1D");
y_fill = [(t_r1d_p + ecart), fliplr(t_r1d_p - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'yellow','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
%---------------
% les ondes R
% on rempli une zone pour materialiser la durée du pulse
plot(delta_x*1e2,t_d_r,LineWidth=2,DisplayName="R direct");
y_fill = [(t_d_r + ecart), fliplr(t_d_r - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, [0.5 0 0.5],'FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
% % la reflexion au bords onde S
plot(delta_x*1e2,t_rb_r,LineWidth=2,DisplayName="R au bord");
y_fill = [(t_rb_r + ecart), fliplr(t_rb_r - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'g','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
% % la reflexion 1D
% plot(delta_x*1e2,t_r1d_p,LineWidth=2,DisplayName="P 1D");
% y_fill = [(t_r1d_p + ecart), fliplr(t_r1d_p - ecart)]; % Y supérieur puis Y inférieur
% fill(x_fill, y_fill, 'yellow','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 


legend;
title("Onde directe VS parasites (sans changement de mode) pour L ="+ L*100 + " cm")
set(gca,fontsize=18)

%% --------------- On regarde que le bas
% INDEPENDANT DE CE QU IL Y A PLUS HAUT OU PRESQUE
% On fixe un delta x raisonable avec le raisonement précédent
disp("cette partie est independante")
vp = 2800;
vs = 1400;
vr = 0.91*vs;
%ecart = 24e-6;% duree du pulse pour f=100 kHz
ecart = 11e-6;% si f= 200 kHz 
dx = 5e-2; % 10 cm
%L = 50e-2;
e = linspace(0,50e-2,100);% differentes epaisseurs 
x_fill = [e, fliplr(e)]*1e2; % X avance puis revient à 0

% trajet direct 
tp_d = e*0 + dx/vp;
tr_d = e*0 + dx/vr;
% une reflexion en bas la plus rapide
tp_rb = sqrt(4*e.^2+dx^2)/vp;



figure;
hold on;
% la reflexion en bas la plus rapide
plot(e*1e2,tp_rb,DisplayName="Onde P reflexion la plus rapide");
y_fill = [(tp_rb + ecart), fliplr(tp_rb - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'r','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
legend
plot(e*1e2,tp_d,DisplayName="Onde P directe"); hold on
y_fill = [(tp_d + ecart), fliplr(tp_d - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'b','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 
% l onde de reyleigh
plot(e*1e2,tr_d,'g',DisplayName="Onde R+S directe"); hold on
y_fill = [(tr_d + ecart), fliplr(tr_d - ecart)]; % Y supérieur puis Y inférieur
fill(x_fill, y_fill, 'g','FaceAlpha', 0.3, 'EdgeColor', 'none','HandleVisibility', 'off'); 

xlabel("epaisseur")
ylabel("temps de premier arrivée au detecteur")
%plot(e,tr_d,DisplayName="Onde R directe")
