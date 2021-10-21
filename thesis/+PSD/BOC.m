% ʹ�ù�ʽ����BOC�źŵĹ������ܶ�
% <Binary Offset Carrier Modulations for Radionavigation>

x = -20:0.01:20;
n = length(x);
y = zeros(1,n);
for k=1:n
    y(k) = G_BOC_even(x(k), 6);
end

figure
plot(x*1.023,10*log10(y), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'Xlim',[-20,20])
set(ax, 'Ylim',[-40,0])
xlabel('Ƶ��/(MHz)')
ylabel('�������ܶ�/(dB/Hz)')

function y = G_BOC_even(f, n)
% nΪ����
y = (tan(pi/2*f/n)*sin(pi*f)/(pi*f))^2;
if f==0
    y = 1e-32;
end

end