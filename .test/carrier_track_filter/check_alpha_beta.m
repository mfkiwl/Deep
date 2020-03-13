%% ��֤alpha-beta�˲�ϵ��
% ���׿������˲�������Ϊalpha-beta�˲�,��ʽ����PI������.
% ������ϵ��,����ͨ������迨�᷽�̻��,Ҳ�����ý��������,���߽��һ��
% alphaΪ��λ����ϵ��,betaΪƵ������ϵ��
% �ɵ����Ĳ���Ϊ:dt,w,v

clear
clc

%% ����
dt = 0.01; %��ɢʱ��
Phi = [1,dt;0,1];
H = [1,0];
w = 0.1; %����������׼��
Q = diag([0,w])^2 * dt^2;
v = 0.1; %����������׼��
R = v^2;

%% �迨�᷽��������alpha,beta
[P,~,~] = idare(Phi',H',Q,R,[],[]); %P��һ��Ԥ�ⷽ������ֵ
EA = Phi*P*Phi'- P - (Phi*P*H')/(H*P*H'+R)*(H*P*Phi') + Q; %�����Ϊ0˵�������ȷ
K = P*H'/(H*P*H'+R); %����������
alpha = K(1);
beta = K(2);
disp([alpha,beta])

%% ��������alpha,beta
% https://en.wikipedia.org/wiki/Alpha_beta_filter
lamda = w/v*dt^2;
r = (4 + lamda - sqrt(8*lamda+lamda^2)) / 4;
alpha = 1-r^2;
beta = (2*(2-alpha) - 4*sqrt(1-alpha)) / dt;
disp([alpha,beta])