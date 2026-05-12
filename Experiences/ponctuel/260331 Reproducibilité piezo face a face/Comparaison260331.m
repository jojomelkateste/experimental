d1 = load("essai_1.mat");
d1_y = load("..\260330\260330_essaie2.mat");
d2 = load("essai_2.mat");
d3 = load("essai_3.mat");
d4 = load("essai_4.mat");
d5 = load("essai_5.mat");
d6 = load("essai_6.mat");
d7 = load("essai_7.mat");
d8 = load("essai_8.mat");
d9 = load("essai_9.mat");
d10 = load("essai_10.mat");
d11 = load("essai_11.mat");
d12 = load("essai_12.mat");
d13 = load("essai_13.mat");
d14 = load("essai_14.mat");
d15 = load("essai_15.mat");

% lire le cahier de manip pour comprendre
bool.Q1 = false; % effet de la repetition dans le temps 
bool.Q1p25 = false;
bool.Q1p5 = false; % Vérifier qu on a plus d'effet d'antenne
bool.Q2V1 = false; % effet du serage
bool.Q2V2 = false; % effet du serage
bool.Q3 = false;
bool.Q4 = false;
bool.Q4_variente = false;
bool.Q5 = true;

if bool.Q5
    d16 = load("essai_16.mat");
    d17 = load("essai_17.mat");
    d18 = load("essai_18.mat");
    d19 = load("essai_19.mat");
    d20 = load("essai_20.mat");
    d21 = load("essai_21.mat");
    d22 = load("essai_22.mat");
    %d23 = load("essai_23.mat");
end

ch1_1 = d1.src1;% emissioN_1
fe_1 = ch1_1.SampleFrequency;    
N_1 = length(ch1_1.Data);
temps_1 = (0:(N_1-1))/fe_1; % 


ch1_2 = d1_y.src1;% emissioN_1
fe_2 = ch1_2.SampleFrequency;    
N_2 = length(ch1_2.Data);
temps_2 = (0:(N_2-1))/fe_2; % 

% ils sont egale c est tres bien 
[~,i1] = max(ch1_1.Data);
[~,i2] = max(ch1_2.Data);

temps_1 = temps_1 - (temps_2(i1)-temps_1(i2)) ;


if bool.Q1
figure;
plot(temps_1,ch1_1.Data)
hold on;
plot(temps_2,ch1_2.Data)
title("Calage des sources")

% plot de la moyenne sur les filtre
figure;
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d1.src2.Data)
plot(temps_2,d1_y.src2.Data)
title("Moyenne sur le filtre")

% plot de la moyenne brute
figure;
subplot(2,1,1)
plot(temps_1,d1.src3.Data)
hold on;
plot(temps_2,d1_y.src3.Data)
title("Moyenne brute")

subplot(2,1,2)
plot(temps_1,d1.src3.Data-mean(d1.src3.Data))
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_2,d1_y.src3.Data-mean(d1_y.src3.Data))
title("Moyenne brute moins moyenne")

end
%% Comparaison 2 Idem mais le meme jours

if bool.Q1p25 
figure;
subplot(2,1,1)
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d1.src2.Data)
plot(temps_1,d2.src2.Data)
title("Moyenne sur le filtre")

subplot(2,1,2)
plot(temps_1,d1.src3.Data-mean(d1.src3.Data))
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_1,d2.src3.Data-mean(d2.src3.Data))
title("Moyenne brute moins moyenne")

sgtitle("Comparaison aujourd hui aujoudhui avec cable encore emélés")
end


if bool.Q1p5
figure;
subplot(2,1,1)
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d1.src2.Data,'b',DisplayName="Cable emele essaie 1")
plot(temps_1,d3.src2.Data,'r',DisplayName="Cable démelle essaie 2")
title("Moyenne sur le filtre")
legend()

subplot(2,1,2)
plot(temps_1,d1.src3.Data-mean(d1.src3.Data),'b')
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_1,d3.src3.Data-mean(d3.src3.Data),'r')
title("Moyenne brute moins moyenne")

sgtitle("Cable demele vs emelé")
end

%% 

if bool.Q2V1
figure;
subplot(2,1,1)
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d3.src2.Data,'b',DisplayName="essai 3")
plot(temps_1,d4.src2.Data,'r',DisplayName="essai 4")
plot(temps_1,d5.src2.Data,'M',DisplayName="essai 5")
title("Moyenne sur le filtre")
legend()

subplot(2,1,2)
plot(temps_1,d3.src3.Data-mean(d3.src3.Data),'b',DisplayName="essai 3")
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_1,d4.src3.Data-mean(d4.src3.Data),'r',DisplayName="essai 4")
plot(temps_1,d5.src3.Data-mean(d5.src3.Data),'M',DisplayName="essai 5")
title("Moyenne brute moins moyenne")
legend()

sgtitle("Effet du serage de la vis")
end

%%



if bool.Q2V2
figure;
subplot(2,1,1)
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d6.src2.Data,'b',DisplayName="essai 6")
plot(temps_1,d7.src2.Data,'g',DisplayName="essai 7")
plot(temps_1,d8.src2.Data,'r',DisplayName="essai 8")
title("Moyenne sur le filtre")
legend()

subplot(2,1,2)
plot(temps_1,d6.src3.Data-mean(d6.src3.Data),'b')
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_1,d7.src3.Data-mean(d7.src3.Data),'r')
plot(temps_1,d8.src3.Data-mean(d8.src3.Data),'M')
title("Moyenne brute moins moyenne")


sgtitle("Q2V2")
end

%% calage a partir essaie 9 

% ils sont egale c est tres bien 
[~,i1] = max(d6.src1.Data);
[~,i2] = max(d9.src1.Data);
temps_2 = temps_1;
temps_1 = temps_1 - (temps_2(i1)-temps_1(i2)) ;

figure;
plot(temps_1,d6.src1.Data)
hold on;
plot(temps_2,d9.src1.Data)
title("Calage des sources")
%%
if bool.Q3
figure;
ax1 = subplot(2,1,1);
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d6.src2.Data,'b',DisplayName="essai 6")
plot(temps_2,d9.src2.Data,'r',DisplayName="essai 9")
title("Moyenne sur le filtre")
legend()

ax2 = subplot(2,1,2);
plot(temps_1,d6.src3.Data-mean(d6.src3.Data),'b')
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_2,d9.src3.Data-mean(d9.src3.Data),'r')
title("Moyenne brute moins moyenne")

sgtitle("Q3")
linkaxes([ax1 ax2],'x')
end

%%
if bool.Q4
figure;
subplot(2,1,1)
plot(temps_1,ch1_1.Data/1.2e6,'k')
hold on;
plot(temps_1,d6.src2.Data,'b',DisplayName="essai 6")
plot(temps_2,d9.src2.Data,'r',DisplayName="essai 9")
plot(temps_2,d10.src2.Data,'M',DisplayName="essai 10")
title("Moyenne sur le filtre")
legend()

subplot(2,1,2)
plot(temps_1,d6.src3.Data-mean(d6.src3.Data),'b')
hold on;
plot(temps_1,ch1_1.Data/1.2e6,'k')
plot(temps_2,d9.src3.Data-mean(d9.src3.Data),'r')
plot(temps_2,d10.src3.Data-mean(d10.src3.Data),'M')
title("Moyenne brute moins moyenne")

sgtitle("Q3")
end


if bool.Q4_variente
    % effet de devisser revisser l emetteur
    figure; 
    ax1 = subplot(2,1,1);
    hold on;
    plot(temps_1,d11.src2.Data,'b',DisplayName="essai 11")
    plot(temps_1,d12.src2.Data,'r',DisplayName="essai 12")
    plot(temps_1,d13.src2.Data,'M',DisplayName="essai 13")
    plot(temps_1,d14.src2.Data,'k--',DisplayName="essai 14 on secoue l emeteur")
    plot(temps_1,d15.src2.Data,'b--',DisplayName="essai 15 devisse et revisse la plaque")
    title("Moyenne sur le filtre")
    legend()
    
    ax2 = subplot(2,1,2);
    hold on
    plot(temps_1,d11.src3.Data,'b',DisplayName="essai 11")
    plot(temps_1,d12.src3.Data,'r',DisplayName="essai 12")
    plot(temps_1,d13.src3.Data,'M',DisplayName="essai 13")
    title("Moyenne brute moins moyenne")
    sgtitle("effet enlever remettre l emetteur")
    legend()
    linkaxes([ax1,ax2],'x')

end

    %% effet du changement d epaisseur
if bool.Q5
    disp("Bloc 008 18 18 4 ")
    figure; 
    ax1 = subplot(2,1,1);
    hold on;
    plot(temps_1,d16.src2.Data,'b',DisplayName="essai 16: 100kHz")
    plot(temps_1,d17.src2.Data,'r',DisplayName="essai 17: 150kHz")
    plot(temps_1,d18.src2.Data,'M',DisplayName="essai 18: 200kHz bis")

    title("Moyenne sur le filtre")
    legend()
    
    ax2 = subplot(2,1,2);
    hold on
    plot(temps_1,d16.src3.Data,'b',DisplayName="essai 16")
    title("Moyenne brute moins moyenne")
    sgtitle("Bloc 18 18 4 plusisuers frequences ")
    legend()
    linkaxes([ax1,ax2],'x')
    %%
    figure; 
    ax1 = subplot(2,1,1);
    hold on;
    plot(temps_1,d19.src2.Data,'b',DisplayName="essai 19: 200kHz bis")
    plot(temps_1,d18.src2.Data,'M--',DisplayName="essai 18: 200kHz bis")
    plot(temps_1,d20.src2.Data,'g.-',DisplayName="essai 20: 200kHz bis")

    title("Moyenne sur le filtre")
    legend()
    
    ax2 = subplot(2,1,2);
    hold on
    plot(temps_1,d19.src3.Data,'b',DisplayName="essai 19")
    plot(temps_1,d20.src3.Data,'M--',DisplayName="essai 20")
    title("Moyenne brute moins moyenne")
    sgtitle("Bloc 18 18 4 plusisuers frequences ")
    legend()
    linkaxes([ax1,ax2],'x')

    %% Plu petit bloc
        figure; 
    ax1 = subplot(2,1,1);
    hold on;
    plot(temps_1,d21.src2.Data,'b',DisplayName="essai 21: 100kHz ")
    plot(temps_1,d22.src2.Data,'M--',DisplayName="essai 22: 150kHz ")

    title("Moyenne sur le filtre")
    legend()
    
    ax2 = subplot(2,1,2);
    hold on
    plot(temps_1,d19.src3.Data,'b',DisplayName="essai 19")
    plot(temps_1,d20.src3.Data,'M--',DisplayName="essai 20")
    title("Moyenne brute moins moyenne")
    sgtitle("Bloc 18 18 4 plusisuers frequences ")
    legend()
    linkaxes([ax1,ax2],'x')
end