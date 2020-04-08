%% IMU���˲���
% ʵ��ʹ��ʱ�����븴�Ƶ��µĽű����޸Ĳ���,����.
% �����������̬������Ҫ3������:
% 1.�Ӽ����������Ϊ������;
% 2.�����������Լ��Ϊ0;
% 3.�˶����(ʹ�ý��ٶ�).
% ������������:
% 1.�����˶������ͺ���,���������������ƫ����ƫһЩ;
% 2.�����˶������������ƫ���ȶ�,����˶���������̬ƫ��,ƫ�ƴ�С��Ӧ�����Ķ�̬����;
% 3.���½��뾲ֹ״̬ʱ,����Ҫ����ˮƽ��̬,������ƫ�Ĺ��ƻ���ͻ��.Ϊ�˷�ֹ��һͻ��,
% �����ھ�ֹ���˶�״̬��ʹ�����鲻ͬ��Q,���˶�ʱ����̬ʧ׼��Q��ýϴ�.�������Q����,
% �˶��ڼ�Q�������ϲ�����̬Ư�Ƶ��ٶ�.

%%
clear
clc

%% ��IMU����
imu = IMU_read(0);
imu(:,1) = []; %ɾ��ʱ����

%% ͳ�����н��ٶȼ��ٶ�ʸ��ģ��
% wm = vecnorm(imu(:,1:3)-mean(imu(1:100,1:3)),2,2);
% fm = vecnorm(imu(:,4:6),2,2);
% figure; plot(wm)
% figure; plot(fm)

%% ����
T = 300; %����ʱ��,s
T0 = 0; %��ʼʱ��,s
dt = 0.01; %��������,s
sigma_gyro = 0.15; %������������׼��,deg/s
sigma_acc = 1.7; %���ٶȼ�������׼��,mg
n = T/dt; %���ݵ���
k0 = T0/dt; %��ʼ�������

%% �����ʼ������ƫ
dgyro0 = mean(imu((1:100)+k0,1:3)); %deg/s,��100����

%% ���㸩���ǹ�ת��
acc = mean(imu((1:100)+k0,4:6)); %��100����
acc = acc / norm(acc);
pitch = asind(acc(1)); %deg
roll = atan2d(-acc(2),-acc(3)); %deg

%% �����˲�������
P = diag([[1,1,1]/180*pi *1, ...   % *deg
          [1,1,1]/180*pi *0.2, ... % *deg/s
          ])^2;
Q1 = diag([[1,1,1]/180*pi *sigma_gyro, ... % *deg/s
           [1,1,1]/180*pi *0.01, ...       % *deg/s/s
           ])^2 * dt^2; %��ֹʱʹ�õ�Q��,��̬ʧ׼�Ƕ�Ӧ��ֵ��������������
Q2 = diag([[1,1,1]/180*pi *sigma_gyro*4, ... % *deg/s
           [1,1,1]/180*pi *0.01, ...       % *deg/s/s
           ])^2 * dt^2; %�˶�ʱʹ�õ�Q��,��̬ʧ׼�Ƕ�Ӧ��ֵ��������,Ҫ��֤P��������ʵ����̬Ư��ƥ��
H = zeros(6);
H(4:6,4:6) = eye(3);
R = diag([[1,1,1]*1e-3*sigma_acc, [1,1,1]/180*pi*sigma_gyro])^2;
% �Ӽ�����ĵ�λ��g

%% ����洢�ռ�
output.att   = zeros(n,3); %��̬���
output.bias  = zeros(n,3); %��������ƫ����
output.P     = zeros(n,6); %P��Խ���Ԫ�ؿ���
output.state = zeros(n,1); %�˶�״̬
output.imu   = zeros(n,6); %IMUԭʼ����
output.wm    = zeros(n,1); %���ٶȵ�ģ��(�����˳�ʼ��ƫ)
output.fm    = zeros(n,1); %���ٶȵ�ģ��

%% ��ֵ
att = [0, pitch, roll] /180*pi; %rad
q = angle2quat(att(1), att(2), att(3));
% dgyro = [0,0,0]; %��������ƫ������,deg/s
dgyro = dgyro0; %�ѳ�ʼ��ƫΪ��ֵ
state = 0; %�˶�״̬,0Ϊ��ֹ,1Ϊ�˶�
cnt = 0; %������

%% ����
g = 9.806;
for k=1:n
    ki = k+k0;
    %----�ж��˶�״̬
    wm = norm(imu(ki,1:3)-dgyro0); %���ٶȵ�ģ,deg/s
    fm = norm(imu(ki,4:6)); %���ٶȵ�ģ,g
    [state, cnt] = motion_state(state, cnt, wm);
    %----�������
    wb = (imu(ki,1:3)-dgyro) /180*pi; %rad/s
    fb = imu(ki,4:6) *g; %m/s^2
    %----��̬����
    Omega = [  0,    wb(1),  wb(2),  wb(3);
            -wb(1),    0,   -wb(3),  wb(2);
            -wb(2),  wb(3),    0,   -wb(1);
            -wb(3), -wb(2),  wb(1),    0 ];
    q = q + 0.5*q*Omega*dt;
    Cnb = quat2dcm(q);
    Cbn = Cnb';
    %----״̬����
    A = zeros(6);
    A(1:3,4:6) = -Cbn;
    Phi = eye(6) + A*dt;
    %----�������
    if state==0 %��ֹ״̬
        %----һ��Ԥ�ⷽ����
        P = Phi*P*Phi' + Q1;
        %----������
        fbg = fb / norm(fb); %��һ��
        Z = [fbg+Cnb(:,3)', wb]';
        %----���ⷽ��
        H(1,1) = -Cnb(1,2);
        H(1,2) =  Cnb(1,1);
        H(2,1) = -Cnb(2,2);
        H(2,2) =  Cnb(2,1);
        H(3,1) = -Cnb(3,2);
        H(3,2) =  Cnb(3,1);
        %----�˲�
        K = P*H' / (H*P*H'+R);
        X = K*Z;
        P = (eye(6)-K*H)*P;
        P = (P+P')/2;
        %----�����������Լ��Ϊ0
        Y = zeros(1,6);
        Y(1) = Cnb(1,1)*Cnb(1,3);
        Y(2) = Cnb(1,2)*Cnb(1,3);
        Y(3) = -(Cnb(1,1)^2+Cnb(1,2)^2);
        X = X - P*Y'/(Y*P*Y')*Y*X;
    else %�˶�״̬
        %----һ��Ԥ�ⷽ����
        P = Phi*P*Phi' + Q2;
        X = zeros(6,1);
    end
    %----����
    q = quatCorr(q, X(1:3)');
    dgyro = dgyro + X(4:6)'/pi*180; %deg/s
    %----�洢
    [r1,r2,r3] = quat2angle(q);
    output.att(k,:) = [r1,r2,r3]/pi*180;
    output.bias(k,:) = dgyro;
    output.P(k,:) = sqrt(diag(P));
    P_angle = var_phi2angle(P(1:3,1:3), Cnb);
    output.P(k,1:3) = sqrt(diag(P_angle));
    output.state(k) = state;
    output.imu(k,:) = imu(ki,:);
    output.wm(k) = wm;
    output.fm(k) = fm;
end

%% ��ͼ
t = (1:n)'*dt;
% ����̬��
figure('Name','��̬��')
for k=1:3
    subplot(3,1,k)
    plot(t,output.att(:,k), 'LineWidth',1)
    grid on
    hold on
    x = output.att(:,k);
    x(output.state==0) = NaN;
    plot(t,x, 'LineWidth',1) %���˶����ֱ��Ϊ�ٻ�
end
% ����������ƫ
figure('Name','��������ƫ')
for k=1:3
    subplot(3,1,k)
    plot(t,output.imu(:,k))
    grid on
    hold on
    plot(t,output.bias(:,k), 'LineWidth',1)
    set(gca, 'ylim', [-1.5,1.5])
end
% ���˶�״̬
figure('Name','�˶�״̬')
plot(t,output.wm)
hold on
grid on
plot(t,output.state, 'LineWidth',1)
set(gca, 'ylim', [-0.5,2])

%% �˶�״̬�ж�
function [state, cnt] = motion_state(state, cnt, wm)
    threshold = 0.8; %deg/s,���ٶ�ģ����ֵ
    if state==0
        if wm<threshold
            cnt = 0;
        else
            cnt = cnt + 1;
        end
        if cnt==3 %��⵽����3������ٶȴ�����ֵ,��Ϊ���˶�״̬
            cnt = 0;
            state = 1;
        end
    else
        if wm>threshold
            cnt = 0;
        else
            cnt = cnt + 1;
        end
        if cnt==200 %��⵽����200������ٶ�С����ֵ,��Ϊ�Ǿ�ֹ״̬
            cnt = 0;
            state = 0;
        end
    end
end