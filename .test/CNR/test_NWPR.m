% ����խ��������ʱ�ֵ��(NWPR)
% ��ͬ������������,NWPR��MM��������С
% NWPR���Լ���ϵ͵������,A/sigma����С��3

CN0 = 45; %�����
T = 0.001; %����ʱ��
N = 20; %С�ε���
M = 20; %ƽ������

n = 1000; %�������
result = zeros(n,1);

A = sqrt(2*T*10^(CN0/10)); %���ַ�ֵ
N_W = zeros(1,M);
for k=1:n
    for m=1:M
        IP = A + randn(1,N); %I·���ֽ��
        QP = randn(1,N); %Q·���ֽ��
        WBP = sum(IP.^2 + QP.^2); %�������,��ƽ�������
        NBP = sum(IP)^2 + sum(QP)^2; %խ�������������ƽ��
        N_W(m) = NBP / WBP;
    end
    Z = mean(N_W);
    S = (Z-1) / (N-Z) / T;
    if S>10
        result(k) = 10*log10(S);
    else
        result(k) = 10;
    end
end

%% ��ɢ��ֲ�
figure
plot(randn(1,n)+A,randn(1,n), 'LineStyle','none', 'Marker','.')
hold on
plot(randn(1,n)-A,randn(1,n), 'LineStyle','none', 'Marker','.')
grid on
axis equal
set(gca, 'Xlim', [-5-A, 5+A])
set(gca, 'Ylim', [-5-A, 5+A])

%% ��������
figure
plot(result)
hold on
grid on
plot([1,n], [CN0,CN0], 'LineWidth',2)
legend('����ֵ','����ֵ')