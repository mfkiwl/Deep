%% ���㲻ͬKF�����µ���̬�˲�������
% ���ǵĲ�����:dt,w,v
% ����������׼��vӦ�ø�����ɢʱ��仯
% �ο�check_alpha_beta.m, order2LoopCoefA.m
% ����ϵ��Ϊ0.707,˵���������˲�����

clear
clc

%% ����
dt = 0.001;
w = logspace(log10(0.01),log10(100),100); %��ѡ�Ĺ���������׼��
v = 0.01;
n = length(w); %�������

%% ����
alpha_beta = zeros(n,2); %��λ,Ƶ������ϵ��
K1_K2 = zeros(n,2); %��������ϵ��
Bn_zeta = zeros(n,2); %���������
for k=1:n
    lamda = w(k)/v*dt^2;
    r = (4 + lamda - sqrt(8*lamda+lamda^2)) / 4;
    alpha = 1-r^2;
    beta = (2*(2-alpha) - 4*sqrt(1-alpha)) / dt;
    alpha_beta(k,:) = [alpha, beta];
    %--------------------------------------------
    K1 = alpha/dt; %PI��������,��λ�����ɱ������Ƶ������,Ҫ���Ի���ʱ��
    K2 = beta/dt; %PI��������,K2���ֲ�ΪƵ������,����ҲҪ���Ի���ʱ��
    K1_K2(k,:) = [K1, K2];
    %--------------------------------------------
    Wn = sqrt(K2);
    zeta = K1/2/Wn;
    Bn = Wn*(4*zeta^2+1) / (8*zeta);
    Bn_zeta(k,:) = [Bn, zeta];
end

%% ��ͼ
figure('Name','alpha-beta')
subplot(2,1,1)
semilogx(w,alpha_beta(:,1))
ylabel('alpha')
grid on
subplot(2,1,2)
semilogx(w,alpha_beta(:,2))
ylabel('beta')
grid on

figure('Name','K1-K2')
subplot(2,1,1)
semilogx(w,K1_K2(:,1))
ylabel('K1')
grid on
subplot(2,1,2)
semilogx(w,K1_K2(:,2))
ylabel('K2')
grid on

figure('Name','Bn-zeta')
subplot(2,1,1)
semilogx(w,Bn_zeta(:,1))
ylabel('Bn')
grid on
subplot(2,1,2)
semilogx(w,Bn_zeta(:,2))
ylabel('zeta')
grid on