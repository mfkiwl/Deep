% ���Զ���DLL�ĸ�������
% ������֤��·����öԲ���
% ���������,��Ƶ�����Ӧ���ܸ����ջ����������Ƶ���ݶ���

%% ָ����·����,����ʱ��,�ź������
Bn = 2; %��·����
T = 0.001; %����ʱ��
CN0 = 48; %�����
n = 100000; %�������ݵ���

%% ����
[Eout, Fout, Pout] = DLL2_cal(Bn, T, CN0, n);

%% ��ͼ
figure
plot(Eout)
grid on
title('����������')
figure
plot(Fout)
grid on
title('��Ƶ�����')
figure
plot(Pout)
grid on
title('����λ���')