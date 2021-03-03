function [Eout, Fout, Pout] = DLL2_cal(Bn, T, CN0, n)
% ����һ�ζ���DLL
% Bn:��·����,Hz
% T:����ʱ��,s
% CN0:�����,dB��Hz
% n:�������
% Eout:����������
% Fout:��Ƶ�����
% Pout:����λ���

[K1, K2] = order2LoopCoefD(Bn, 0.707, T); %��·ϵ��
A = sqrt(2*T*10^(CN0/10)); %���ַ�ֵ

Eout = zeros(1,n);
Fout = zeros(1,n);
Pout = zeros(1,n);

x1 = 0; %��Ƶ��,Hz
x2 = 0; %����λ,��Ƭ

noiseE = (randn(1,n) + randn(1,n)*1j) / sqrt(2); %��ǰ·������,��Ϊ�������,���Է�ֵ��sqrt(2)
noiseL = (randn(1,n) + randn(1,n)*1j) / sqrt(2); %�ͺ�·������

for k=1:n
    SE = abs(A*(1-(x2+0.3))+noiseE(k)); %��ǰ·��ֵ
    SL = abs(A*(1+(x2-0.3))+noiseL(k)); %�ͺ�·��ֵ
    e = 0.7 * (SE-SL) / (SE+SL); %����������
%     SE = abs(A*(1-1.5*(x2+0.3))+noiseE(k)); %��ǰ·��ֵ
%     SL = abs(A*(1+1.5*(x2-0.3))+noiseL(k)); %�ͺ�·��ֵ
%     e = (11/30) * (SE-SL) / (SE+SL) / 2; %����������
    x1 = x1 + K2*e; %������Ƶ��
    x2 = x2 + (K1*e+x1)*T; %��������λ
    Eout(k) = e;
    Fout(k) = x1;
    Pout(k) = x2;
end

end