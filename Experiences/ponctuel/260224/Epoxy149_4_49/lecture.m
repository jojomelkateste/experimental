% Experience 1
d = load('E1_face149.mat');
fe = d.src1.SampleFrequency;    
N = length(d.src1.Data);
temps = (0:(N-1))/fe; % temps 

figure;
% subplot(1,2,1)
% plot(temps,d.src1.Data)
% subplot(1,2,2)
plot(temps,d.src2.Data)

figure;
plot(temps,log(abs(d.src2.Data)));

t1=0.00112092;
t2=0.00115631;
d= 14.9e-2;
disp(d/(t2-t1))