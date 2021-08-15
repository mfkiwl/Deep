% α���ʲ�������������ȵĹ�ϵ����
clear
clc

x = 25:55;
T = 0.02; %����ʱ��
CN0 = 10.^(x/10);
zeta = sqrt(0.5);

Bn = 25;
y1 = 1/(2*pi)*sqrt((1.89*Bn)^3/8/zeta./CN0.*(1+1./(2*T*CN0)))*0.2;
Bn = 20;
y2 = 1/(2*pi)*sqrt((1.89*Bn)^3/8/zeta./CN0.*(1+1./(2*T*CN0)))*0.2;
Bn = 15;
y3 = 1/(2*pi)*sqrt((1.89*Bn)^3/8/zeta./CN0.*(1+1./(2*T*CN0)))*0.2;
Bn = 10;
y4 = 1/(2*pi)*sqrt((1.89*Bn)^3/8/zeta./CN0.*(1+1./(2*T*CN0)))*0.2;
Bn = 5;
y5 = 1/(2*pi)*sqrt((1.89*Bn)^3/8/zeta./CN0.*(1+1./(2*T*CN0)))*0.2;

figure('Position',[488,242,560,500])
semilogy(x,y1, 'LineWidth',2)
hold on
grid on
semilogy(x,y2, 'LineWidth',2)
semilogy(x,y3, 'LineWidth',2)
semilogy(x,y4, 'LineWidth',2)
semilogy(x,y5, 'LineWidth',2)

ax = gca;
set(ax, 'FontSize',12)
xlabel('�����/(dB��Hz)')
ylabel('α���ʲ���������׼��/(m/s)')
legend('25Hz','20Hz','15Hz','10Hz','5Hz', 'Location','northeast')
set(ax, 'YLim',[4e-4,0.4])