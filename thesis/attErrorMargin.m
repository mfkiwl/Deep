% ˫����ʸ�������ʱ,��̬���ԣ������߳��ȵĹ�ϵ����

l = 0.2:0.1:3; %���߳���
phi = 2*asind(0.2*0.19/2./l); %��̬���ԣ��,��λ���ԣ��0.2��

figure
plot(l,phi, 'LineWidth',2)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'Ylim', [0,10])
xlabel('���߳���/(m)')
ylabel('��̬���ԣ��/(��)')