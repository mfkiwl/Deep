%% ��֤��ֹ״̬�����ٶ�Ϊ����Ĺߵ��˲�
% ״̬��:��̬ʧ׼��,�ٶ����,��������ƫ
% ������:�ٶ����

clear
clc

%% ��������
cond.T = 50;
cond.dt = 0.01;
cond.sigma_gyro = 0.1; %deg/s
cond.sigma_acc = 1; %mg
cond.bias_gyro = [0.1, 0.2, 0.1]*1; %deg/s
cond.bias_acc = [0, 0, -3]*0; %mg
cond.att = [50, 0, 0]; %��ʵ��̬,[yaw,pitch,roll],deg

%% ����IMU����
imu = imu_gene(cond);

%% �����˲�������
dt = cond.dt;
sigma_gyro = cond.sigma_gyro;
sigma_acc = cond.sigma_acc;
P = diag([[1,1,1]/180*pi *1, ...   % *deg
          [1,1,1]        *1, ...   % *m/s
          [1,1,1]/180*pi *0.1  ... % *deg/s
          ])^2;
Q = diag([[1,1,1]/180*pi *sigma_gyro, ... % *deg/s
          [1,1,1]*0.01   *sigma_acc, ...  % *mg
          [1,1,1]/180*pi *0.01 ...        % *deg/s/s
          ])^2 * dt^2;
H = zeros(3,9);
H(1:3,4:6) = eye(3);
R = diag([1,1,1]*0.01)^2;

%% ����洢�ռ�
n = cond.T/cond.dt;
output.nav = zeros(n,6);
output.bias = zeros(n,6);
output.P = zeros(n,9);

%% ��ֵ
att = (cond.att + [0, 1, 2]) /180*pi; %rad
q = angle2quat(att(1), att(2), att(3)); %������
v = [0, 0, 0]; %������
dgyro = [0,0,0]; %��������ƫ������,deg/s
dacc = [0,0,0]; %���ٶȼ���ƫ������,g

%% ����
g = 9.8;
for k=1:n
    %----�������
    wb = (imu(k,1:3)-dgyro) /180*pi; %rad/s
    fb = (imu(k,4:6)-dacc) *g; %m/s^2
    %----��̬����
    Cnb = quat2dcm(q);
    C11 = Cnb(1,1); %Լ������ǲ���ʱ�õ�
    C12 = Cnb(1,2);
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
    %----״̬����
    A = zeros(9);
    A(1:3,7:9) = -Cbn;
    A(4:6,1:3) = [0,-fn(3),fn(2); fn(3),0,-fn(1); -fn(2),fn(1),0];
    Phi = eye(9) + A*dt;
    %----�˲�
    Z = v' + randn(3,1)*0.01;
    P = Phi*P*Phi' + Q;
    K = P*H' / (H*P*H'+R);
    X = K*Z;
    P = (eye(9)-K*H)*P;
    P = (P+P')/2;
    %----״̬Լ��(ֻ����һ��)
        %++++�����������Լ��Ϊ0
%         Y = zeros(1,9);
%         Y(1) = Cnb(1,1)*Cnb(1,3);
%         Y(2) = Cnb(1,2)*Cnb(1,3);
%         Y(3) = -(Cnb(1,1)^2+Cnb(1,2)^2);
%         X = X - P*Y'/(Y*P*Y')*Y*X;
        %++++�����Լ��Ϊ����
%         Y = zeros(1,9);
%         Y(1) = C11*Cnb(1,3);
%         Y(2) = C12*Cnb(1,3);
%         Y(3) = -(C11*Cnb(1,1)+C12*Cnb(1,2));
%         d = C11*Cnb(1,2) - C12*Cnb(1,1);
%         X = X - P*Y'/(Y*P*Y')*(Y*X-d);
    %----����
    phi = norm(X(1:3));
    if phi>1e-6
        qc = [cos(phi/2), X(1:3)'/phi*sin(phi/2)];
        q = quatmultiply(qc, q);
    end
    q = q / norm(q);
    v = v - X(4:6)';
    dgyro = dgyro + X(7:9)'/pi*180; %deg/s
    %----�洢
    [r1,r2,r3] = quat2angle(q);
    output.nav(k,1:3) = [r1,r2,r3]/pi*180;
    output.nav(k,4:6) = v;
    output.bias(k,1:3) = dgyro;
    output.bias(k,4:6) = dacc;
    output.P(k,:) = sqrt(diag(P));
    P_angle = var_phi2angle(P(1:3,1:3), Cnb);
    output.P(k,1:3) = sqrt(diag(P_angle));
end

%% ��ͼ
t = (1:n)*dt;
plot_att_error(t, output.nav(:,1:3)-ones(n,1)*cond.att, output.P(:,1:3))
plot_vel_error(t, output.nav(:,4:6), output.P(:,4:6))
plot_gyro_esti(t, output.bias(:,1:3), cond.bias_gyro, output.P(:,7:9))