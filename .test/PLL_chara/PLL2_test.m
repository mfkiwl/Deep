% ���Զ���PLL�ĸ�������
% ������֤��·����öԲ���
% ���������,�ز�Ƶ�����Ӧ���ܸ����ջ����������Ƶ���ݶ���

%% ָ����·����,����ʱ��,�ź������
Bn = 25; %��·����
T = 0.001; %����ʱ��
CN0 = 48; %�����
n = 100000; %�������ݵ���

%% ����
[Eout, Fout, Pout] = PLL2_cal(Bn, T, CN0, n);

%% ��ͼ
figure
plot(Eout)
grid on
title('�ز����������')
figure
plot(Fout)
grid on
title('�ز�Ƶ�����')
figure
plot(Pout)
grid on
title('�ز���λ���')