clear
% ne plus utiliser d = load("C:\Users\melka\Desktop\Experimental\Experiences\Pierre_mareuil\Exp1.mat");
%d = load("C:\Users\melka\Desktop\Experimental\Experiences\Pierre_mareuil\Exp2.mat");
d = load("C:\Users\melka\Desktop\Experimental\Experiences\Pierre_mareuil\Exp3.mat");
ch1 = d.src1;% reception

fe = ch1.SampleFrequency;    
N = length(ch1.Data);
temps = (0:(N-1))/fe; % tem

ch1 = ch1.Data;
ch2 = d.src2.Data;% emission
ch3 = d.src3.Data;% emission


ch3 = ch3 -mean(ch3);
%% -- Afficher les signaux 

figure;
ax1= subplot(2,1,1);
plot(temps,ch1,'b')
hold on;
plot(temps,ch3,'k--')
ax2= subplot(2,1,2);
plot(temps,ch2,'r')

%% 


figure;
ax1= subplot(2,1,1);
plot(temps,log(abs(ch1)),'b')
ax2= subplot(2,1,2);
plot(temps,log(abs(ch2)),'r')


%% 
figure;
plot(ch3)

%%
pic1 = zeros(size(ch3));
pic1(5134:6866) = ch3(5134:6866);

[m1,t1_i] = max(abs(pic1));
t1 = temps(t1_i);

pic2 = zeros(size(ch3));
pic2(6866:7900) = ch3(6866:7900);

[m2,t2_i] = max(abs(pic2));
t2 = temps(t2_i);


figure;
plot(temps,abs(ch3))
hold on;
plot(temps,abs(pic1))
plot(temps,abs(pic2))
scatter(t1,m1)
scatter(t2,m2)


%% -- travail en frequenciel
freq = (-N/2:N/2-1)*(fe/N);
e = 1.9e-2;
[data_array] = map_pulses2data(freq,{pic1,pic2},e);
data_array = data_array{1};

freq = data_array.freq;
vg = data_array.vg;

figure;
plot(freq,vg)
xlim([900e3,1100e3])
hold on;
scatter(1e6,2*e/(t2-t1))