% �ز�Ƶ�ʱ仯�ʵ��ز���λ�ķ�Ƶ��Ӧ����
clear
clc

w = {1e-0*2*pi, 1e2*2*pi}; %����Ƶ�ʷ�Χ,rad/s

Bn = 25; %����
[K1, K2] = order2LoopCoefA(Bn, sqrt(0.5)); %ϵ��
H1 = tf(1, [1,K1,K2]);
[mag1,phase1,wout1] = bode(H1, w);
mag1 = reshape(mag1,size(mag1,3),1); %�ų�������
phase1 = reshape(phase1,size(phase1,3),1);
wout1 = wout1/2/pi; %Hz

Bn = 20; %����
[K1, K2] = order2LoopCoefA(Bn, sqrt(0.5)); %ϵ��
H2 = tf(1, [1,K1,K2]);
[mag2,phase2,wout2] = bode(H2, w);
mag2 = reshape(mag2,size(mag2,3),1); %�ų�������
phase2 = reshape(phase2,size(phase2,3),1);
wout2 = wout2/2/pi; %Hz

Bn = 15; %����
[K1, K2] = order2LoopCoefA(Bn, sqrt(0.5)); %ϵ��
H3 = tf(1, [1,K1,K2]);
[mag3,phase3,wout3] = bode(H3, w);
mag3 = reshape(mag3,size(mag3,3),1); %�ų�������
phase3 = reshape(phase3,size(phase3,3),1);
wout3 = wout3/2/pi; %Hz

Bn = 10; %����
[K1, K2] = order2LoopCoefA(Bn, sqrt(0.5)); %ϵ��
H4 = tf(1, [1,K1,K2]);
[mag4,phase4,wout4] = bode(H4, w);
mag4 = reshape(mag4,size(mag4,3),1); %�ų�������
phase4 = reshape(phase4,size(phase4,3),1);
wout4 = wout4/2/pi; %Hz

Bn = 5; %����
[K1, K2] = order2LoopCoefA(Bn, sqrt(0.5)); %ϵ��
H5 = tf(1, [1,K1,K2]);
[mag5,phase5,wout5] = bode(H5, w);
mag5 = reshape(mag5,size(mag5,3),1); %�ų�������
phase5 = reshape(phase5,size(phase5,3),1);
wout5 = wout5/2/pi; %Hz

figure
loglog(wout1, mag1, 'LineWidth',2)
grid on
hold on
loglog(wout2, mag2, 'LineWidth',2)
loglog(wout3, mag3, 'LineWidth',2)
loglog(wout4, mag4, 'LineWidth',2)
loglog(wout5, mag5, 'LineWidth',2)

% sqrt(0.01/19.1/25^3) 25Hz���������,����ӳ��ϵ��
loglog([1,100],[1.83e-4,1.83e-4], 'Color','r', 'LineStyle','--', 'LineWidth',1)

ax = gca;
set(ax, 'FontSize',12)
xlabel('Ƶ��/(Hz)')
ylabel('������ֵ˥��ϵ��')
legend('25Hz','20Hz','15Hz','10Hz','5Hz', 'Location','northeast')