% ��ֹ-����-תȦ-����-��ֹ (0.2g)
syms t

%% ˮƽ�ٶ�
VhFun = [];
VhFun{1,1} = [0,30];     VhFun{1,2} = 0;
VhFun{2,1} = [30,40];    VhFun{2,2} = 2*(t-30);
VhFun{3,1} = [40,80];    VhFun{3,2} = 20;
VhFun{4,1} = [80,90];    VhFun{4,2} = 20-2*(t-80);
VhFun{5,1} = 90;         VhFun{5,2} = 0;

%% �ٶȷ���
VyFun = [];
VyFun{1,1} = [0,50];     VyFun{1,2} = 45;
VyFun{2,1} = [50,70];    VyFun{2,2} = 45+18*(t-50);
VyFun{3,1} = 70;         VyFun{3,2} = 405;

%% �����ٶ�
VuFun = [];
VuFun{1,1} = 0;          VuFun{1,2} = 0;

%% �����
AyFun = [];
AyFun{1,1} = [0,50];     AyFun{1,2} = 45;
AyFun{2,1} = [50,70];    AyFun{2,2} = 45+18*(t-50);
AyFun{3,1} = 70;         AyFun{3,2} = 405;

%% ������
ApFun = [];
ApFun{1,1} = 0;          ApFun{1,2} = 0;

%% ��ת��
ArFun = [];
ArFun{1,1} = 0;          ArFun{1,2} = 0;
