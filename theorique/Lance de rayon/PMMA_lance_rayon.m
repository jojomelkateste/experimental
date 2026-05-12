vp=2800;
vs=1400;
vr=1275;
x = linspace(0,50)*10^-2;
d = @(dx) sqrt((2e-2)^2 + dx.^2);

e = 45;% duree du pulse 

figure;
y = d(x)/vp*10^6;
plot(x*10^2,y,'LineWidth', 2)
hold on;
fill([x*10^2 fliplr(x*10^2)], [y+e fliplr(y-e)], ...
     [0.2 0.6 1], ...        % couleur (bleu clair)
     'FaceAlpha', 0.3, ...   % transparence
     'EdgeColor', 'none');   % pas de bord
y = d(x)/vs*10^6;
plot(x*10^2,y,'LineWidth', 2)
fill([x*10^2 fliplr(x*10^2)], [y+e fliplr(y-e)], ...
     [1 0.6 0.2], ...        % couleur (bleu clair)
     'FaceAlpha', 0.3, ...   % transparence
     'EdgeColor', 'none');   % pas de bord
xlabel("Temps d arive prévu en seconde",'FontSize', 25)
ylabel("Offeset x",'FontSize', 25)
legend(["Onde P","Onde S"])
set(gca,"FontSize",25)