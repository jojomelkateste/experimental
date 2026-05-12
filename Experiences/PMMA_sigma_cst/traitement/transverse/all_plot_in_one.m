LineWidth = 5;
bool_xlim = true; % pour limiter en fréquences dans l affichage
delta_f_affichage = 0.15e6; % pourczentage de la frequence centrale pour r
base_name = "window_str_rect__fc_";
fichiers = [];
% de 0.5 à 0.9 Mhz
for i=5:9
    name = base_name+"0p"+i+".mat";
    fichiers = [fichiers,name];
end
% de 1 à 1p5 Mhz
for i=0:3
    name = base_name+"1p"+i+".mat";
    fichiers = [fichiers,name];
end
nfile = length(fichiers);
% fichiers = ["window_str_rect__fc_0p5.mat", ...
%             "window_str_rect__fc_0p6.mat", ...
%             "window_str_rect__fc_0p7.mat", ...
%             "window_str_rect__fc_0p8.mat"];
%preparation de la figure
figure;
subplot(2,1,1)
hold on;
subplot(2,2,3)
hold on
subplot(2,2,4)
hold on;
% preparation des tableau pour les error bars
vg_temp2vol = zeros(1,nfile);
err_vg = zeros(1,nfile);
ki_r = zeros(1,nfile);
ki_err = zeros(1,nfile);
Q = zeros(1,nfile);
Q_err = zeros(1,nfile);
real_fc_list = zeros(1,nfile);

for i=1:nfile
    file = fichiers(i);
    [output] = data_mean_std2plot(file);
    
    % recuperation de toutes les variable dans le field 
    noms = fieldnames(output);
    for k = 1:numel(noms)
        nom = noms{k};
        assignin('base', nom, output.(nom));
    end
    vg_temp2vol(i) = temps2vol.vg_temp2vol;
    err_vg(i)      = temps2vol.err_vg;
    ki_r(i)        = temps2vol.ki_r;
    ki_err(i)      = temps2vol.ki_err;
    Q(i)           = temps2vol.Q;
    Q_err(i)       = temps2vol.Q_err;
    real_fc_list(i) = real_fc; % variable alors disponible

    % noms = fieldnames(temps2vol);
    % for k = 1:numel(noms)
    %     nom = noms{k};
    %     assignin('base', nom, temps2vol.(nom));
    % end
    % plot de la vitesse
    subplot(2,1,1);
    plot(freq,vg_mean,LineWidth=LineWidth,Color="black")
    plot(freq,vg_mean+vg_std,"r--",LineWidth=LineWidth/2)
    plot(freq,vg_mean-vg_std,"r--",LineWidth=LineWidth/2)
    fill([freq fliplr(freq)], [vg_mean-vg_std, fliplr(vg_mean+vg_std)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    % if bool_xlim
    %     xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    % end
    
    % plot de im(k)
    subplot(2,2,3);
    plot(freq,imk_mean,LineWidth=LineWidth,Color="black")
    plot(freq,imk_mean+imk_std,"r--",LineWidth=LineWidth/2)
    plot(freq,imk_mean-imk_std,"r--",LineWidth=LineWidth/2)
    fill([freq fliplr(freq)], [imk_mean-imk_std, fliplr(imk_mean+imk_std)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    % if bool_xlim
    %     xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    % end
    title("im(k)")
    
    subplot(2,2,4);
    plot(freq,Q_mean,LineWidth=LineWidth,Color="black")
    plot(freq,Q_mean+Q_std,"r--",LineWidth=LineWidth/2)
    plot(freq,Q_mean-Q_std,"r--",LineWidth=LineWidth/2)
    fill([freq fliplr(freq)], [Q_mean-Q_std, fliplr(Q_mean+Q_std)], ...
         'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    % if bool_xlim
    %     xlim([real_fc-delta_f_affichage,real_fc+delta_f_affichage])
    % end
    title("Q factor")
    %sgtitle(titre)
    % ici faire tout les plots avec le hold on qui attend
end

% par temps de vol
subplot(2,1,1)
errorbar(real_fc_list, vg_temp2vol, err_vg, err_vg, 0, 0, ...
    'LineStyle','none', ...
    'Marker','+', ...
    'MarkerSize',25, ...
    'LineWidth',LineWidth/2,Color="black");
subplot(2,2,3)
errorbar(real_fc_list, ki_r, ki_err, ki_err, 0, 0, ...
'LineStyle','none', ...
'Marker','+', ...
'MarkerSize',25, ...
'LineWidth',LineWidth/2,Color="black");

subplot(2,2,4)
errorbar(real_fc_list, Q, Q_err, Q_err, 0, 0, ...
    'LineStyle','none', ...
    'Marker','+', ...
    'MarkerSize',25, ...
    'LineWidth',LineWidth/2,Color="black");

[filename, pathname] = uiputfile({'*.png';'*.jpg';'*.pdf';'*.fig'}, ...
                                 'Choisir un nom pour la figure');

if isequal(filename,0)
    disp('Sauvegarde annulée');
else
    saveas(gcf, fullfile(pathname, filename));
end