% ���Ծط���(MM)
% GNSS Solutions: Carrier-to-Noise Algorithms
% �������ʱ,�ı����ʱ�䲻Ӱ���������,һ�μ����ö��ٵ�Ӱ���������
% �������ʱ��Ҫ��߻���ʱ��,��������㲻����
% A/sigma>3ʱ���ܵõ��Ϻõļ�����

CN0 = 45; %�����
T = 0.001; %����ʱ��
N = 400; %һ���ö��ٵ�

n = 1000; %�������
result = zeros(n,1);

A = sqrt(2*T*10^(CN0/10)); %���ַ�ֵ
for k=1:n
    IP = A + randn(1,N); %I·���ֽ��
    QP = randn(1,N); %Q·���ֽ��
    M2 = sum(IP.^2+QP.^2)/N; %���׾�
    M4 = sum((IP.^2+QP.^2).^2)/N; %�Ľ׾�
    Pd = sqrt(2*M2^2 - M4); %�źŹ���
    Pn = M2 - Pd; %��������
    lamda = Pd / Pn; %���ʱ�
    result(k) = 10*log10(lamda/T);
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