% ��ֹ��ת
syms t

%% ˮƽ�ٶ�
VhFun = [];
VhFun{1,1} = 0;          VhFun{1,2} = 0;

%% �ٶȷ���
VyFun = [];
VyFun{1,1} = 0;          VyFun{1,2} = 0;

%% �����ٶ�
VuFun = [];
VuFun{1,1} = 0;          VuFun{1,2} = 0;

%% �����
AyFun = [];
AyFun{1,1} = 0;          AyFun{1,2} = 0;

%% ������
ApFun = [];
ApFun{1,1} = 0;          ApFun{1,2} = 0;

%% ��ת��
ArFun = [];
ArFun{1,1} = [0,30];     ArFun{1,2} = 0;
ArFun{2,1} = [30,48];    ArFun{2,2} = 60*(t-30);
ArFun{3,1} = 48;         ArFun{3,2} = 1080;
