% ���μ���
syms t

%% ˮƽ�ٶ�
VhFun = [];
VhFun{1,1} = [0,30];     VhFun{1,2} = 0;
VhFun{2,1} = [30,40];    VhFun{2,2} = 30*(t-30);
VhFun{3,1} = [40,50];    VhFun{3,2} = 300;
VhFun{4,1} = [50,55];    VhFun{4,2} = 300+30*(t-50);
VhFun{5,1} = 55;         VhFun{5,2} = 450;

%% �ٶȷ���
VyFun = [];
VyFun{1,1} = 0;          VyFun{1,2} = 90;

%% �����ٶ�
VuFun = [];
VuFun{1,1} = 0;          VuFun{1,2} = 0;

%% �����
AyFun = [];
AyFun{1,1} = 0;          AyFun{1,2} = 90;

%% ������
ApFun = [];
ApFun{1,1} = 0;          ApFun{1,2} = 0;

%% ��ת��
ArFun = [];
ArFun{1,1} = 0;          ArFun{1,2} = 0;
