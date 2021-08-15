% ���ٶ���λ��������ٶ�������׼��Ĺ�ϵ����
clear
clc

x = logspace(-3,0,100); %0.001~1m/s^2
Timu = 0.01;

coef = 5*360; %��λ��λ�Ƕ�,5Ϊ����ϵ��
Bn = 25;
y1 = sqrt(Timu/19.1/Bn^3)*x*coef;
Bn = 20;
y2 = sqrt(Timu/19.1/Bn^3)*x*coef;
Bn = 15;
y3 = sqrt(Timu/19.1/Bn^3)*x*coef;
Bn = 10;
y4 = sqrt(Timu/19.1/Bn^3)*x*coef;
Bn = 5;
y5 = sqrt(Timu/19.1/Bn^3)*x*coef;

figure('Position',[488,242,560,500])
loglog(x,y1, 'LineWidth',2)
hold on
grid on
loglog(x,y2, 'LineWidth',2)
loglog(x,y3, 'LineWidth',2)
loglog(x,y4, 'LineWidth',2)
loglog(x,y5, 'LineWidth',2)

ax = gca;
set(ax, 'FontSize',12)
xlabel('���ٶ�������׼��/(m/s^2)')
ylabel('���ٶ���λ����/(��,1\sigma)')
legend('25Hz','20Hz','15Hz','10Hz','5Hz', 'Location','northwest')
set(ax, 'YLim',[2e-4,5])