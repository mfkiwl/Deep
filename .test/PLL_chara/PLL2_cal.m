function [Eout, Fout, Pout] = PLL2_cal(Bn, T, CN0, n)
% ����һ�ζ���PLL
% Bn:��·����,Hz
% T:����ʱ��,s
% CN0:�����,dB��Hz
% n:�������
% Eout:�ز����������
% Fout:�ز�Ƶ�����
% Pout:�ز���λ���

[K1, K2] = order2LoopCoefD(Bn, 0.707, T); %��·ϵ��
A = sqrt(2*T*10^(CN0/10)); %���ַ�ֵ

Eout = zeros(1,n);
Fout = zeros(1,n);
Pout = zeros(1,n);

x1 = 0; %�ز�Ƶ��,Hz
x2 = 0; %�ز���λ,��

noise = randn(1,n) + randn(1,n)*1j; %������

for k=1:n
    e = -angle(A*exp(2j*pi*x2)+noise(k)) /(2*pi); %�ز����������,��
    x1 = x1 + K2*e; %�����ز�Ƶ��
    x2 = x2 + (K1*e+x1)*T; %�����ز���λ
    Eout(k) = e;
    Fout(k) = x1;
    Pout(k) = x2;
end

end