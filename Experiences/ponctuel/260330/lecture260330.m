

file_name_base ="260330_essaie";
for i=1:4
    file = file_name_base+i+".mat";
    d = load(file);
    ch1 = d.src1;% reception
    fe = ch1.SampleFrequency;    
    N = length(ch1.Data);
    temps = (0:(N-1))/fe; % tem
    ch1 = ch1.Data;
    ch2 = d.src2.Data;
    figure;
    ax1 = subplot(2,1,1);
    plot(ax1,temps,ch1)
    ax2 = subplot(2,1,2);
    plot(ax2,temps,ch2)
    sgtitle("Essai :"+i)
    linkaxes([ax1 ax2], 'x');   % Lie les axes X
end
