d = load('test100kHz.mat')
figure;
hold on;
for k = 1:length(d)
    plot(d.freq,d{k}.vg)
end
