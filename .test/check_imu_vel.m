%% IMU���ٲ���
% ʵ��ʹ��ʱ�����븴�Ƶ��µĽű����޸Ĳ���,����.
% 1.��ֹʱ���ٶ�0�����������Ϊ����;
% 2.�����������Լ��Ϊ0;
% 3.�˶����(ʹ�ý��ٶ�).
% �ο�check_imu_att.m

%%
clear
clc

%% ��IMU����
imu = IMU_read(0);
imu(:,1) = []; %ɾ��ʱ����

%% ����
T = 100; %����ʱ��,s
T0 = 0; %��ʼʱ��,s
dt = 0.01; %��������,s
sigma_gyro = 0.15; %������������׼��,deg/s
sigma_acc = 1.7; %���ٶȼ�������׼��,mg
sigma_v = 0.01; %���ٶ����������õ�,m/s
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
          [1,1,1]        *1, ...   % *m/s
          [1,1,1]/180*pi *0.2, ... % *deg/s
          [1,1,1]*0.01   *1 ...    % *mg
          ])^2;
Q1 = diag([[1,1,1]/180*pi *sigma_gyro, ... % *deg/s
           [1,1,1]*0.01   *sigma_acc, ...  % *mg
           [1,1,1]/180*pi *0.01, ...       % *deg/s/s
           [1,1,1]*0.01   *0.1 ...         % *mg/s:
           ])^2 * dt^2;
Q2 = diag([[1,1,1]/180*pi *sigma_gyro, ... % *deg/s
           [1,1,1]*0.01   *sigma_acc, ...  % *mg
           [1,1,1]/180*pi *0.01, ...       % *deg/s/s
           [1,1,1]*0.01   *0.1 ...         % *mg/s:
           ])^2 * dt^2;
H = zeros(6,12);
H(1:3,4:6) = eye(3); %�ٶ�����
H(4:6,7:9) = eye(3); %���ٶ�����
R = diag([[1,1,1]*sigma_v, [1,1,1]/180*pi*sigma_gyro])^2;

%% ����洢�ռ�
output.nav   = zeros(n,9); %�������,��̬�ٶ�λ��
output.bias  = zeros(n,6); %�����ǺͼӼ���ƫ����
output.P     = zeros(n,12); %P��Խ���Ԫ�ؿ���
output.state = zeros(n,1); %�˶�״̬
output.imu   = zeros(n,6); %IMUԭʼ����
output.wm    = zeros(n,1); %���ٶȵ�ģ��(�����˳�ʼ��ƫ)
output.fm    = zeros(n,1); %���ٶȵ�ģ��

%% ��ֵ
att = [0, pitch, roll] /180*pi; %rad
q = angle2quat(att(1), att(2), att(3));
v = [0, 0, 0];
p = [0, 0, 0];
% dgyro = [0,0,0]; %��������ƫ������,deg/s
dgyro = dgyro0; %�ѳ�ʼ��ƫΪ��ֵ
dacc = [0,0,0]; %���ٶȼ���ƫ������,g
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
    fb = (imu(ki,4:6)-dacc) *g; %m/s^2
    %----��̬����
    Omega = [  0,    wb(1),  wb(2),  wb(3);
            -wb(1),    0,   -wb(3),  wb(2);
            -wb(2),  wb(3),    0,   -wb(1);
            -wb(3), -wb(2),  wb(1),    0 ];
    q = q + 0.5*q*Omega*dt;
    Cnb = quat2dcm(q);
    Cbn = Cnb';
    %----�ٶȽ���
    fn = fb*Cnb;
    v = v + (fn+[0,0,g])*dt;
    %----λ�ý���
    p = p + v*dt;
    %----״̬����
    A = zeros(12);
    A(1:3,7:9) = -Cbn;
    A(4:6,1:3) = [0,-fn(3),fn(2); fn(3),0,-fn(1); -fn(2),fn(1),0];
    A(4:6,10:12) = Cbn;
    Phi = eye(12) + A*dt;
    %----�������
    if state==0 %��ֹ״̬
        %----һ��Ԥ�ⷽ����
        P = Phi*P*Phi' + Q1;
        %----������
        Z = [v, wb]';
        %----�˲�
        K = P*H' / (H*P*H'+R);
        X = K*Z;
        P = (eye(12)-K*H)*P;
        P = (P+P')/2;
        %----�����������Լ��Ϊ0
        Y = zeros(1,12);
        Y(1) = Cnb(1,1)*Cnb(1,3);
        Y(2) = Cnb(1,2)*Cnb(1,3);
        Y(3) = -(Cnb(1,1)^2+Cnb(1,2)^2);
        X = X - P*Y'/(Y*P*Y')*Y*X;
    else %�˶�״̬
        %----һ��Ԥ�ⷽ����
        P = Phi*P*Phi' + Q2;
        X = zeros(12,1);
    end
    %----����
    q = quatCorr(q, X(1:3)');
    v = v - X(4:6)';
    dgyro = dgyro + X(7:9)'/pi*180; %deg/s
	dacc = dacc + X(10:12)'/g; %g
    %----�洢
    [r1,r2,r3] = quat2angle(q);
    output.nav(k,1:3) = [r1,r2,r3]/pi*180;
    output.nav(k,4:6) = v;
    output.nav(k,7:9) = p;
    output.bias(k,1:3) = dgyro;
    output.bias(k,4:6) = dacc;
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
    plot(t,output.nav(:,k), 'LineWidth',1)
    grid on
    hold on
    x = output.nav(:,k);
    x(output.state==0) = NaN;
    plot(t,x, 'LineWidth',1) %���˶����ֱ��Ϊ�ٻ�
end
% ���ٶ�
figure('Name','�ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t,output.nav(:,k+3), 'LineWidth',1)
    grid on
    hold on
    x = output.nav(:,k+3);
    x(output.state==0) = NaN;
    plot(t,x, 'LineWidth',1) %���˶����ֱ��Ϊ�ٻ�
end
% ��λ��
figure('Name','λ��')
for k=1:3
    subplot(3,1,k)
    plot(t,output.nav(:,k+6), 'LineWidth',1)
    grid on
    hold on
    x = output.nav(:,k+6);
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
% �����ٶȼ���ƫ
figure('Name','���ٶȼ���ƫ')
for k=1:3
    subplot(3,1,k)
    plot(t,output.bias(:,k+3), 'LineWidth',1)
    grid on
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