% �켣������

clear
clc

%% �켣����
traj1; %ѡ��켣����
p = [45.7364, 126.70775, 165]; %��ʼλ��
Ts = 60; %�켣ʱ��
dt = 0.005; %�켣����

%% ���켣�Ƿ���ȷ
trajFun_check(VhFun, 'VhFun')
trajFun_check(VyFun, 'VyFun')
trajFun_check(VuFun, 'VuFun')
trajFun_check(AyFun, 'AyFun')
trajFun_check(ApFun, 'ApFun')
trajFun_check(ArFun, 'ArFun')

%% ���ɹ켣��
trajTable = [trajFun_process(VhFun);
             trajFun_process(VyFun);
             trajFun_process(VuFun);
             trajFun_process(AyFun);
             trajFun_process(ApFun);
             trajFun_process(ArFun)];

%% ���ݴ洢�ռ�
N = Ts/dt + 1; %�������
vel_ned  = zeros(N,3); %����ϵ�ٶ�
pos_lla  = zeros(N,3); %γ����
pos_ecef = zeros(N,3); %ecefλ��
angle    = zeros(N,3); %��̬��
acc      = zeros(N,3); %���ٶ�
omega    = zeros(N,3); %���ٶ�

%% ����ÿ��ʱ�̵�״̬
index = ones(1,6); %ʱ����������
cmd = zeros(2,6); %��һ��Ϊֵ,�ڶ���Ϊ����
d2r = pi/180;
r2d = 180/pi;
w = 7.292115e-5; %������ת���ٶ�
for k=1:N
    t = (k-1)*dt; %��ǰʱ��
    %----��������,��ȡֵ
    for m=1:6
        if index(m)<trajTable{m,2} && trajTable{m,1}(index(m)+1)<t
            index(m) = index(m) + 1; %��������
        end
        valueFun = trajTable{m,3}{index(m)}; %ֵ����
        if isnumeric(valueFun)
            cmd(1,m) = valueFun;
        else
            cmd(1,m) = valueFun(t);
        end
        diffFun = trajTable{m,4}{index(m)}; %��������
        if isnumeric(diffFun)
            cmd(2,m) = diffFun;
        else
            cmd(2,m) = diffFun(t);
        end
    end
    %----�����ٶ�
	vh = cmd(1,1); %ˮƽ�ٶ�
    vy = cmd(1,2); %�ٶȷ���
    cos_vy = cosd(vy);
    sin_vy = sind(vy);
    v = [vh*cos_vy, vh*sin_vy, -cmd(1,3)]; %�������ٶ�
    %----�������ʰ뾶
    lat = p(1);
    lon = p(2);
    h = p(3);
    [Rm, Rn] = earthCurveRadius(lat);
    %----����λ��(��һ�β�����)
    if k>1
        dp = (v0+v)/2*dt;
        lat = lat + dp(1)/(Rm+h)*r2d;
        lon = lon + dp(2)*secd(lat)/(Rn+h)*r2d;
        h = h - dp(3);
        p = [lat, lon, h];
    end
    %----������ٶ�,���ٶ�
    psi = cmd(1,4)*d2r;
    theta = cmd(1,5)*d2r;
    gamma = cmd(1,6)*d2r;
    Cnb = angle2dcm(psi, theta, gamma);
    Cbn = Cnb';
    vh_dot = cmd(2,1);
    vy_dot = cmd(2,2)*d2r;
    v_dot = [vh_dot*cos_vy-vh*sin_vy*vy_dot, ...
             vh_dot*sin_vy+vh*cos_vy*vy_dot, ...
             -cmd(2,3)]; %�ٶȱ仯��
    a_dot = cmd(2,4:6)*d2r; %��̬�Ǳ仯��
    g = gravitywgs84(h, lat); %�������ٶ�
    wnbb = a_dot * [-sin(theta), sin(gamma)*cos(theta), cos(gamma)*cos(theta);
                    0, cos(gamma), -sin(gamma); 1, 0, 0];
    wien = [w*cosd(lat), 0, -w*sind(lat)];
    wenn = [v(2)/(Rn+h), -v(1)/(Rm+h), -v(2)/(Rn+h)*tand(lat)];
    fn = v_dot - [0,0,g] + cross(2*wien+wenn,v);
    fb = fn*Cbn;
    wibb = (wien+wenn)*Cbn + wnbb;
    %----��¼�ϴε��ٶ�
    v0 = v;
    %----�洢
    vel_ned(k,:) = v;
    pos_lla(k,:) = p;
    pos_ecef(k,:) = lla2ecef(p);
    [r1,r2,r3] = dcm2angle(Cnb);
    angle(k,:) = [r1,r2,r3]*r2d;
    acc(k,:) = fb; %m/s^2
    omega(k,:) = wibb*r2d; %deg/s
end

%% ����켣
traj = [pos_ecef, angle, pos_lla, vel_ned, omega, acc];
save('~temp\traj.mat', 'traj', 'dt');

%% ��ͼ
t = (0:N-1)*dt;
figure %----λ��
subplot(3,1,1)
plot(t, pos_lla(:,1), 'LineWidth',1)
grid on
subplot(3,1,2)
plot(t, pos_lla(:,2), 'LineWidth',1)
grid on
subplot(3,1,3)
plot(t, pos_lla(:,3), 'LineWidth',1)
grid on
figure %----�ٶ�
subplot(3,1,1)
plot(t, vel_ned(:,1), 'LineWidth',1)
grid on
subplot(3,1,2)
plot(t, vel_ned(:,2), 'LineWidth',1)
grid on
subplot(3,1,3)
plot(t, vel_ned(:,3), 'LineWidth',1)
grid on
figure %----��̬
subplot(3,1,1)
plot(t, angle(:,1), 'LineWidth',1)
grid on
subplot(3,1,2)
plot(t, angle(:,2), 'LineWidth',1)
grid on
subplot(3,1,3)
plot(t, angle(:,3), 'LineWidth',1)
grid on