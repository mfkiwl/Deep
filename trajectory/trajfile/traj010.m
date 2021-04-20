% 8���͹켣
syms t

L = 10000; %�켣����
V = 200; %ƽ���ٶ�
h = 500; %�߶ȱ仯
S = L/14.94375529901562;
w = 2*pi*V/L;

%% ˮƽ�ٶ�
VhFun = [];
VhFun{1,1} = 0;          VhFun{1,2} = sqrt((3*S*w*cos(w*t))^2+(2*S*w*(cos(w*t)^2-sin(w*t)^2))^2);

%% �ٶȷ���
VyFun = [];
VyFun{1,1} = 0;          VyFun{1,2} = atan2d(2*S*w*(cos(w*t)^2-sin(w*t)^2), 3*S*w*cos(w*t));

%% �����ٶ�
VuFun = [];
VuFun{1,1} = 0;          VuFun{1,2} = 0.5*h*w*sin(w*t);

%% �����
AyFun = [];
AyFun{1,1} = 0;          AyFun{1,2} = atan2d(2*S*w*(cos(w*t)^2-sin(w*t)^2), 3*S*w*cos(w*t));

%% ������
ApFun = [];
ApFun{1,1} = 0;          ApFun{1,2} = 0;

%% ��ת��
ArFun = [];
ArFun{1,1} = 0;          ArFun{1,2} = 0;
