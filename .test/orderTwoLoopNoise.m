% ������׻��������
% 2Hz���������������Ϊ0.07 (sqrt(2/500),1000Hz����Ƶ��)
% 25Hz���������������Ϊ0.22 (sqrt(25/500),1000Hz����Ƶ��) 6.15�ٶȱ���
% ��Ч��������Ϊ����

[K1, K2] = orderTwoLoopCoef(25, 0.707, 1);

n = 100*1000; %�ܵ���
dt = 0.001; %ʱ����
X = randn(n,1); %����
Y = zeros(n,1); %���
V = zeros(n,1); %������

x1 = 0; %�������������
x2 = 0; %�ܻ������
for k=1:n
    e = X(k) - x2;
    x1 = x1 + K2*e*dt;
    x2 = x2 + (K1*e+x1)*dt;
    Y(k) = x2;
    V(k) = x1;
end

figure
plot((1:n)*dt, X)
hold on
plot((1:n)*dt, Y)
figure
plot((1:n)*dt, V)

disp(std(Y)) %���������׼��
disp(std(V))

function [K1, K2] = orderTwoLoopCoef(LBW, zeta, k)
% ���׻�·ϵ��
%   Inputs:
%       LBW           - Loop noise bandwidth
%       zeta          - Damping ratio
%       k             - Loop gain
%
%   Outputs:
%       K1, K2        - Loop filter coefficients 

% Solve natural frequency
Wn = LBW*8*zeta / (4*zeta^2 + 1);

% solve for K1 & K2
K1 = 2*zeta*Wn / k;
K2 = Wn^2 / k;

end