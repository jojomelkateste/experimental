% concatenatin des 
bool_xlim = true;
delta_f_affichage = 0.15e6;

base_name = "window_str_rect__fc_";
% fichiers = [];
% % de 0.5 à 0.9 Mhz
% for i=5:9
%     name = base_name+"0p"+i+".mat";
%     fichiers = [fichiers,name];
% end
% % de 1 à 1p5 Mhz
% for i=0:5
%     name = base_name+"1p"+i+".mat";
%     fichiers = [fichiers,name];
% end
%%
fichiers = ["window_str_rect__fc_0p5.mat", ...
            "window_str_rect__fc_0p6.mat", ...
            "window_str_rect__fc_0p7.mat", ...
            "window_str_rect__fc_0p8.mat"];

axList_vp = [];
axList_ik = [];
axList_Q = [];

for f = fichiers
    [~, axes2] = plot_post_traitement(f, ...
        "bool_xlim",bool_xlim, ...
        "delta_f_affichage",delta_f_affichage, ...
        Visible="off");

    axList_vp(end+1) = axes2.s1;   % on récupère le subplot s1
    axList_ik(end+1) = axes2.s2;
    axList_Q(end+1) = axes2.s3;
end

figure;
axOut = subplot(1,1,1);
merge_many_subplots(axOut, axList_vp);
title("Fusion de tous les plots vg");

figure;
axOut = subplot(1,1,1);
merge_many_subplots(axOut, axList_ik);
title("Fusion de tous les plots im(k)");

figure;
axOut = subplot(1,1,1);
merge_many_subplots(axOut, axList_Q);
title("Fusion de tous les plots Q");

%%
function axOut = merge_many_subplots(axOut, axList)
    % axOut  : axe de destination
    % axList : tableau de handles d'axes à fusionner

    if nargin < 1 || isempty(axOut)
        figure;
        axOut = axes;
    end

    hold(axOut, 'on');

    for k = 1:numel(axList)
        ax = axList(k);

        % if ~isvalid(ax)
        %     warning("Axe %d invalide, ignoré.", k);
        %     continue;
        % end

        % Récupérer les objets graphiques
        children = get(ax, 'Children');

        % Copier dans l’axe final
        copyobj(children, axOut);
    end

    hold(axOut, 'off');

    % Optionnel : reprendre les limites du premier axe
    if ~isempty(axList)
        axRef = axList(1);
        xlim(axOut, get(axRef, 'XLim'));
        ylim(axOut, get(axRef, 'YLim'));
        xlabel(axOut, get(get(axRef, 'XLabel'), 'String'));
        ylabel(axOut, get(get(axRef, 'YLabel'), 'String'));
    end
end


%%
% bool_xlim = true; % pour limiter en fréquences dans l affichage
% delta_f_affichage = 0.15e6; % pourczentage de la frequence centrale pour r
% 
% [~,axes2] = plot_post_traitement("window_str_rect__fc_0p5.mat", ...
%      "bool_xlim",bool_xlim,"delta_f_affichage",delta_f_affichage,titre="0.5Mhz", ...
%      Visible='off');
% 
% ax_vp = axes2.s1;
% % ax_ik = axes2.s2;
% % ax_Q = axes2.s3;
% 
% figure;
% axNew = show_axis_in_new_figure(ax_vp);
% delete(ax_vp)
% title("vp")
% 
% [~,axes2] = plot_post_traitement("window_str_rect__fc_0p6.mat", ...
%      "bool_xlim",bool_xlim,"delta_f_affichage",delta_f_affichage,titre="0.5Mhz", ...
%      Visible='off');
% ax_vp = axes2.s1;
% % ax_ik = axes2.s2;
% % ax_Q = axes2.s3;
% 
% %%
% [~,ax1] = plot_post_traitement("window_str_rect__fc_0p5.mat", ...
%     "bool_xlim",bool_xlim,"delta_f_affichage",delta_f_affichage,titre="0.5Mhz");
% sgtitle("0.5Mhz")
% [~,ax2] = plot_post_traitement("window_str_rect__fc_0p6.mat", ...
%     "bool_xlim",bool_xlim,"delta_f_affichage",delta_f_affichage,titre="0.6Mhz");
% 
% % concaténation des plots
% figure;
% ax = subplot(1,1,1);
% merge_subplots(ax1.s1, ax2.s1, ax);
%%

% function axOut = merge_subplots(ax1, ax2, axOut)
%     % merge_subplots fusionne le contenu de ax1 et ax2 dans un seul axe.
%     %
%     % ax1, ax2 : handles des axes existants (subplots)
%     % axOut    : (optionnel) axe de destination.
%     %            Si non fourni, un nouvel axe plein écran est créé.
%     %
%     % Retour :
%     %   axOut : handle de l'axe contenant tous les tracés
% 
%     if nargin < 3 || isempty(axOut)
%         figure;
%         axOut = axes;  % nouvel axe
%     end
% 
%     % Copier le contenu de ax1 vers axOut
%     ch1 = get(ax1, 'Children');
%     copyobj(ch1, axOut);
% 
%     % Copier le contenu de ax2 vers axOut
%     ch2 = get(ax2, 'Children');
%     copyobj(ch2, axOut);
% 
%     % Optionnel : harmoniser les limites, labels, titre, etc.
%     xlim(axOut, get(ax1, 'XLim'));
%     ylim(axOut, get(ax1, 'YLim'));
%     xlabel(axOut, get(get(ax1, 'XLabel'), 'String'));
%     ylabel(axOut, get(get(ax1, 'YLabel'), 'String'));
%     title(axOut, 'Fusion des deux subplots');
% end
% 
% 
% function axNew = show_axis_in_new_figure(axOld)
% 
%     % Crée une nouvelle figure visible
%     figure;
%     axNew = axes;
% 
%     % Récupère les objets graphiques de l'ancien axe
%     children = get(axOld, 'Children');
% 
%     % Copie les objets dans le nouvel axe
%     copyobj(children, axNew);
% 
%     % Copie les limites, labels, titre, etc.
%     xlim(axNew, get(axOld, 'XLim'));
%     ylim(axNew, get(axOld, 'YLim'));
%     xlabel(axNew, get(get(axOld, 'XLabel'), 'String'));
%     ylabel(axNew, get(get(axOld, 'YLabel'), 'String'));
%     title(axNew, get(get(axOld, 'Title'), 'String'));
% end