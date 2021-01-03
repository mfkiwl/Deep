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
acc      = zeros(N-1,3); %���ٶ�
omega    = zeros(N-1,3); %���ٶ�

%% ����ÿ��ʱ�̵�״̬
index = ones(1,6); %ʱ����������
cmd = zeros(2,6); %��һ��Ϊֵ,�ڶ���Ϊ����
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
    %----����
	vh = cmd(1,1); %ˮƽ�ٶ�
    vy = cmd(1,2); %�ٶȷ���
    v = [vh*cosd(vy), vh*sind(vy), -cmd(1,3)]; %�������ٶ�
    if k>1 %��һ���ǳ�ֵ
        lat = p(1);
        h = p(3);
        [Rm, Rn] = earthCurveRadius(lat);
        dp = (v0+v)/2*dt;
        p(1) = p(1) + dp(1)/(Rm+h) /pi*180;
        p(2) = p(2) + dp(2)*secd(lat)/(Rn+h) /pi*180;
        p(3) = p(3) - dp(3);
    end
    v0 = v; %��¼�ϴε��ٶ�
    %----�洢
    vel_ned(k,:) = v;
    pos_lla(k,:) = p;
    pos_ecef(k,:) = lla2ecef(p);
    angle(k,:) = cmd(1,4:6);
    if k>1
%         acc(k-1,:) = fb;
%         omega(k-1,:) = wb;
    end
end

%% ����켣
traj = [pos_ecef, pos_lla, vel_ned, angle, ...
        [[NaN,NaN,NaN];omega], [[NaN,NaN,NaN];acc]];
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