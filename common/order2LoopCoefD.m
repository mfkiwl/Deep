function [K1, K2] = order2LoopCoefD(Bn, zeta, T)
% ��ɢ���׻�·ϵ��
% Bn:��·��������,Hz,loop noise bandwidth
% zeta:����ϵ��,damping ratio
% T:����ʱ�䲽��,s
% �μ�<Software Defined Radio using MATLAB Simulink and the RTL-SDR> P601

theta = Bn*T / (zeta+0.25/zeta); %D.49

K1 = 4*zeta*theta / (1+2*zeta*theta+theta^2) / T; %D.50
K2 = 4*theta^2 / (1+2*zeta*theta+theta^2) / T; %D.51
% ������T��Դ��NCO,��ɢģ����û�п���ʱ�䲽��,��Ҫ���ⲹ��

end