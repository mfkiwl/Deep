function [K1, K2] = order2LoopCoefA(Bn, zeta)
% ģ����׻�·ϵ��
% Bn:��·��������,Hz,loop noise bandwidth
% zeta:����ϵ��,damping ratio
% �μ�<Software Defined Radio using MATLAB Simulink and the RTL-SDR> D2��¼

Wn = Bn*8*zeta / (4*zeta^2 + 1); %D.48

K1 = 2*zeta*Wn; %D.24�����Ǿ仰
K2 = Wn^2;

end