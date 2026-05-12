% dimensionner le bloc pour mesurer

% jolie graphique
% 1. Nettoyage des propriétés précédentes
set(groot, 'default') 

% 2. Police et Texte (Lissage et lisibilité)
% set(groot, 'defaultTickLabelInterpreter', 'latex');
% set(groot, 'defaultTextInterpreter', 'latex');
% set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultAxesFontName', 'Helvetica');

% 3. Épaisseurs et Lignes
set(groot, 'defaultLineLineWidth', 1.8);        % Lignes plus épaisses
set(groot, 'defaultAxesLineWidth', 1.1);       % Cadre de l'axe plus marqué
set(groot, 'defaultFunctionLineLineWidth', 1.8);

set(groot, 'defaultAxesBox', 'on');             % Encadrer le graphique
set(groot, 'defaultAxesXGrid', 'on');           % Grille légère
set(groot, 'defaultAxesYGrid', 'on');
set(groot, 'defaultAxesGridLineStyle', ':');
set(groot, 'defaultAxesGridAlpha', 0.5);

% 5. Taille des marqueurs
set(groot, 'defaultLineMarkerSize', 8);
%% Mesurer en face a face avec des ondes 
% S sans reflexion du P au bord

% le nom etalement selon les frequences
zmax = @(a,lambda) a^2./lambda -lambda/4;

c= 2500;
f100 = 100e3;
z_100 = zmax(40e-3,c/f100);
z_200 = zmax(40e-3,c/(2*f100));

dx = 2.5e-2;% à 200 kHz

L_min = @(e,dx) sqrt(8*e.^2+dx^2+6*e*dx);

figure; 
e = linspace(0,10e-2);
plot(e,L_min(e,dx),'b',DisplayName="L min a 200 kHz")
xline(dx,'b--',DisplayName="epaisseur minimum 200 kHz") % minimum a 
hold on;
plot(e,L_min(e,2*dx),DisplayName="L min a 100 kHz")
xline(2*dx,'r--',DisplayName="epaisseur minimum 100 kHz")
% 
xline(z_100,"k-.",DisplayName="Champ proche a 100 kHz")
%xline(z_200,"M-.",DisplayName="Champ proche a 200 kHz")
legend;
xr = xregion(2*dx, z_100);

% Personnalisation
xr.FaceColor = [0.2 0.8 0.2]; % Vert
xr.FaceAlpha = 0.2;           % Transparence (0 à 1)
xr.EdgeColor = 'none';        % Enlever les bords

%% Le semi infinie

