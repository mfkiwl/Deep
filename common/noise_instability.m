function N = noise_instability(n, m)
% ������ƫ���ȶ�������
% n:���ݸ���
% m:����ά��
% �ο�Matlab imuSensor

N = zeros(n,m);
y = zeros(1,m);
for k=1:n
    y = 0.5*y + randn(1,m);
    N(k,:) = y;
end

end