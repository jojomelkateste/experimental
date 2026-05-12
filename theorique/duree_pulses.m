clear, close all;
fc= 200e3;
f = linspace(fc/100,10*fc,1000); Nf = length(f);
% df = f(2)-f(1);
% dt = 1/(df*Nf);
% t = 0:dt:1/df/100;
t = linspace(0,40*10^-6,10000);
w = 2*pi*f;
alpha = pi*fc;
t0 = 0.2e-4;
beta = t0;
RF = ricker_freq(w,alpha,beta);
RT = ricker_temporel(t,alpha,beta);

% % plot du ricker
% figure
subplot(1,2,1)
plot(f,abs(RF))
subplot(1,2,2)
hold on
plot(t*10^6,(RT))

%%
% recherche de la duree du pulse à 
eps = 1e-4;
[M,ind] = max(RT);
% detection de la sortie du bruit
ind_0 = ind;
for i=1:length(RT)
    %scatter(t(i),RT(i))
    if abs(RT(i))>=M*eps
        ind_0 = i;
        break
    end
end

disp(t(ind_0))
disp(RT(ind_0))
scatter(t(ind_0)*1e6,RT(ind_0 ))
disp("Duree du pulse = "+ (t(ind)-t(ind_0))*2*1e6 +"µs" )