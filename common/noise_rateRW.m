function N = noise_rateRW(n, m)
% �������������������
% n:���ݸ���
% m:����ά��
% �ο�Matlab imuSensor

N = zeros(n,m);
y = zeros(1,m);
for k=1:n
    y = y + randn(1,m);
    N(k,:) = y;
end

end