 zmax = @(a,lambda) a^2./lambda -lambda/4;


%a = 28e-3/2; % capteur a 100 kHz
a = 20e-3; % capteur a 250 kHz

 f = linspace(50e3,500e3,1000);
 c = 2500; % vp

 ll = c./f; %lambda

 y = zmax(a,ll);

 if any(isinf(y))
     disp("attention inf")
 end


figure;
plot(f/1000,y*100)
ylabel("Distance en cm")
xlabel("frequences en khz")