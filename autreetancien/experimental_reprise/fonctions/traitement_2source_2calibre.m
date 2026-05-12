function [data_traite] = traitement_2source_2calibre(S,Szoom,e,fc, MinPeakHeight,MinPeakDistance)
    % traitement_2source_2calibre Cette fonction fait la même chose que
    % traitement_automatique mais avec deux fichiers pour un calibre et un
    % calibre zoom.
    %pour 
    %   Detailed explanation goes here
    % arguments (Input)
    %     src objet avec les différentes data src1 src2
    %     e eppaisseur parcouru 
    %     fc frequence central pour le traitementg 
    % end
    arguments
        S
        Szoom
        e 
        fc 
        MinPeakHeight = 0.05
        MinPeakDistance = 200
    end
    %% Nouveau code
    em1 = S.src1.Data ;%emmeteur 
    disp("Pour le moment je n utilise pas le dezoom de l emission")
    emz = Szoom.src1.Data ; % emmeteur zoom
    re1 = S.src2.Data;% recepteur
    rez = Szoom.src2.Data;
    
    
    % verifier ici que src.SampleFrequency; est tous le meme
    % verifier que N est le memem pour tous
    fe = S.src1.SampleFrequency;
    N = length(em1);
    temps = (0:(N-1))/fe; % temps 
    freq = (-N/2:N/2-1)*(fe/N);
    
    % 1er etape nettoyer le signal émis
    [emz] = remove_noise_bis(emz ,freq,fe); % nettoyage du bruit
    emz = emz-mean(emz); % mise à 0 
    f = figure;
    plot(emz);
    title("Noter l'indice jusqu'ou mettre des zeros pour supprimer le premier pic du champ émis")

    % Label et edit pour Indice
    uicontrol(f, 'Style','text', ...
             'Units','normalized', ...
             'Position',[0.05 0.12 0.2 0.04], ...
             'String','Indice?', ...
             'HorizontalAlignment','left', ...
             'FontWeight','bold');
    editIndice = uicontrol(f, 'Style','edit', ...
                         'Units','normalized', ...
                         'Position',[0.05 0.03 0.2 0.08], ...
                         'String','0');
    
    % Label et edit pour MinPeakDistance
    uicontrol(f, 'Style','text', ...
             'Units','normalized', ...
             'Position',[0.3 0.12 0.25 0.04], ...
             'String','MinPeakDistance?', ...
             'HorizontalAlignment','left', ...
             'FontWeight','bold');
    editMinPeakDistance = uicontrol(f, 'Style','edit', ...
                         'Units','normalized', ...
                         'Position',[0.3 0.03 0.25 0.08], ...
                         'String','200');
    
    % Label et edit pour MinPeakHeight
    uicontrol(f, 'Style','text', ...
             'Units','normalized', ...
             'Position',[0.6 0.12 0.25 0.04], ...
             'String','MinPeakHeight?', ...
             'HorizontalAlignment','left', ...
             'FontWeight','bold');
    editMinPeakHeight = uicontrol(f, 'Style','edit', ...
                         'Units','normalized', ...
                         'Position',[0.6 0.03 0.25 0.08], ...
                         'String','0.05');
    
    % Bouton Valider
    uicontrol(f, 'Style','pushbutton', ...
             'Units','normalized', ...
             'Position',[0.88 0.03 0.1 0.08], ...
             'String','Valider', ...
             'FontWeight','bold', ...
             'Callback', @(~,~) uiresume(f));

    % Attendre que l'utilisateur clique sur Valider
    uiwait(f);

    % Récupérer les valeurs
    v = str2double(editIndice.String);
    MinPeakDistance = str2double(editMinPeakDistance.String);
    MinPeakHeight = str2double(editMinPeakHeight.String);
    emz(1:v) = 0 ; % on supprime le 1er pic
    emz = remove_noise_bis(emz ,freq,fe); % on redebruite le signal 
    %close f;
    figure;
    plot(emz);
    
    
    [pic,pic_times,pulse_array] = pulse_detection(temps,emz,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);





    error("Fonction pas fini")
    %% Ancien code

    d = 2*e;

    u = src.Data; %champ de deplacement
    fe = src.SampleFrequency;
    N = length(u);
    temps = (0:(N-1))/fe; % temps 
    freq = (-N/2:N/2-1)*(fe/N);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Detection des pics
    % Amelioration a faire ici
    % MinPeakHeight = 0.05;%max(uclean)/30;%0.004
    % MinPeakDistance = 200;% 1e-5

    [uclean] = remove_noise_bis(u,freq,fe);
    [pic,pic_times,pulse_array] = pulse_detection(temps,uclean,MinPeakHeight=MinPeakHeight,MinPeakDistance=MinPeakDistance);
    Npulse = length(pulse_array);
    %data_traite.pulse_array=pulse_array;
    % pulse_detection permets de detecter 
    % on peut inserer ici quelque chose pour adapter MinPeakHeight et
    % MinPeakDistance
    disp("Amelioration: permettre le chois des parametre pour déterminer les pics")
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % On fait verifier qu on a bien la frequence centrale qu on pense avoir
    f = figure;
    plot(freq,abs(fftshift(fft(pulse_array{1}))))
    title("Verifier que fc= "+fc)
    % Crée un bouton "Continuer"
    btn = uicontrol('Style','pushbutton','String','Fc ok',...
        'Position',[20 20 100 30],...
        'Callback',@(src,~) uiresume(f));
    % --- Bouton 2 : "Kill" (Arrêter la fonction) ---
    btn_kill = uicontrol('Style','pushbutton','String','KILL (Arrêter)',...
        'Position',[320 20 100 30],...
        'BackgroundColor', [0.8 0.4 0.4], ...
        'Callback', @(src,event) close(f));
    % Note : Les parenthèses sont optionnelles mais améliorent la lisibilité
    uiwait(f);   % attend que uiresume soit appelé
    delete(btn); % supprime le bouton avant la prochaine boucle
    delete(btn_kill)
    if ~isvalid(f)
        % Si la fenêtre 'f' n'est plus valide, c'est qu'elle a été fermée 
        % (soit par le bouton KILL, soit par la croix rouge en haut à droite).
        error('Arrêt volontaire du programme par l''utilisateur.');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Recuperation des pulses
    f = figure;   % <-- stocke le handle de la figure
    title("Vérifier les pulse et noter les indices du dernier pulse")
    hold on;
    for i = 1:Npulse
        plot(uclean);
        plot(pulse_array{i});

        % Crée un bouton "Continuer"
        btn = uicontrol('Style','pushbutton','String','Continuer',...
            'Position',[20 20 100 30],...
            'Callback',@(src,~) uiresume(f));

        uiwait(f);   % attend que uiresume soit appelé
        delete(btn); % supprime le bouton avant la prochaine boucle
        cla;         % nettoie l'axe
    end
    % Fenêtre de saisie avec inputdlg et conversion en entier
    prompt = {'Entrez i1 (13354):', 'Entrez i2 (14164):'};
    dlgtitle = 'Saisie de deux entiers';
    dims = [1 30];
    definput = {'0','0'};   % valeurs par défaut

    answer = inputdlg(prompt, dlgtitle, dims, definput);

    % Conversion en entiers
    i1 = str2double(answer{1});
    i2 = str2double(answer{2});
    
    % on modifie le dernier pulse retenu
    pulse = zeros(1,length(uclean));
    pulse(i1:i2) = uclean(i1:i2);
    pulse_array{end} =pulse;
    plot(uclean);
    plot(pulse_array{end});

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calcul du temps de vol
    temps2vol =  d./(pic_times(2:end)-pic_times(1:end-1)); 
    data_traite.temps2vol = temps2vol; % sauvegarde du temps de vol
    data_traite.pic = pic;
    % Calcul du facteur d'attenuation avec les pics
    d_pic = 2*e*(1:length(pic_times));
    p = polyfit(d_pic, log(pic), 1);
    kpp = - p(1);
    data_traite.kpp = kpp;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vg_array = cell(1,Npulse-1);
    Q_array  = cell(1,Npulse-1);
    % freq_bis c est toujours le meme donc ok 
    reK_array = cell(1,Npulse-1);
    imK_array = cell(1,Npulse-1);
    for i=1:Npulse-1
        pulse1 = pulse_array{i};
        pulse2 = pulse_array{i+1};
        %[vg,Q_factor,freq_bis,reK,imK] = spectrale_analysis(pulse1,pulse2,freq,fc,d);
        %%%%% recopie de spectrale_analysis
        pulse1_fft = fftshift(ifft(pulse1));
        pulse2_fft = fftshift(ifft(pulse2));
        % Il peut il y avoir trop de point on ne prend que la zone d'interet
        pulse1_fft = pulse1_fft(freq>fc-0.1e6 & freq<fc+0.1e6);
        pulse2_fft = pulse2_fft(freq>fc-0.1e6 & freq<fc+0.1e6);
        freq_bis = freq(freq>fc-0.1e6 & freq<fc+0.1e6);
        RS         = pulse2_fft(:)./pulse1_fft(:); % Rapport spectrale
        reK        = unwrap(angle(RS))/d; reK = reK'; % bonne dimension
        imK        = -log(abs(RS))/d;     imK = imK'; % bonne dimension
        % calcul de la vitesse de groupe d omega /dk
        vg = 2*pi*(freq_bis(2:end)-freq_bis(1:(end-1)))./(reK(2:end)-reK(1:(end-1)));
        Q_factor = 0.5*reK./imK ;
        %%%%%
        vg_array{i} = vg;
        Q_array{i} = Q_factor;
        reK_array{i} = reK;
        imK_array{i} = imK;
    end
    data_traite.freq_bis  = freq_bis;
    data_traite.vg_array  = vg_array;
    data_traite.Q_array   = Q_array;
    data_traite.reK_array = reK_array;
    data_traite.imK_array = imK_array;
end