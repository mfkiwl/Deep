%% ���Խ���ϵ����˲���(��ֹ���)

%%
clear
clc

%% ����ʱ��
T = 200;       %��ʱ��
dt = 0.01;     %ʱ����
n = T / dt;    %�������
t = (1:n)'*dt; %ʱ������,������

%% ��������ָ��
sigma_gyro = 0.15; %deg/s
sigma_acc = 1.5e-3; %g
bias_gyro = [0.2, 0, 0.6] *1; %deg/s
bias_acc = [0, 0, 2]*1e-3 *1; %g

%% ���ջ�ָ��
sigma_rho = 3; %m
sigma_rhodot = 0.1; %m/s
dtr = 1e-8; %��ʼ�Ӳ�,s
dtv = 3e-9; %��Ƶ��,s/s
c = 299792458;

%% λ�ú���̬
p0 = [46, 126, 200];
rp = lla2ecef(p0);
a0 = [50, 0, 0]; %deg

%% ����λ��
% ��һ��Ϊ��λ��,�ڶ���Ϊ�߶Ƚ�,deg
sv_info = [  0, 45;
            23, 28;
            58, 80;
           100, 49;
           146, 34;
           186, 78;
           213, 43;
           255, 15;
           310, 20];
rho = 20000000; %���ǵ����ջ��ľ���,m

%% ��������������
d2r = pi/180;
Cnb = angle2dcm(a0(1)*d2r, a0(2)*d2r, a0(3)*d2r);
acc = (Cnb*[0;0;-1])'; %��ʵ���ٶ�,g
imu = zeros(n,6);
imu(:,1:3) = ones(n,1)*bias_gyro + ...
             randn(n,3)*sigma_gyro;
imu(:,4:6) = ones(n,1)*acc + ...
             ones(n,1)*bias_acc + ...
             randn(n,3)*sigma_acc; 

%% ��������λ���ٶ�
svN = size(sv_info,1); %���Ǹ���
sv_real = zeros(svN,8);
G = zeros(svN,4);
G(:,4) = -1;
Cen = dcmecef2ned(p0(1), p0(2));
for k=1:svN
    e = [-cosd(sv_info(k,2))*cosd(sv_info(k,1)), ...
         -cosd(sv_info(k,2))*sind(sv_info(k,1)), ...
          sind(sv_info(k,2))]; %����ָ����ջ��ĵ�λʸ��
	rsp = e * rho; %����ָ����ջ���λ��ʸ��
    sv_real(k,1:3) = rp - (rsp*Cen); %����λ��
    sv_real(k,4:6) = 0; %�����ٶ�
    sv_real(k,7) = rho; %α��
    sv_real(k,8) = 0; %α����
    G(k,1:3) = e;
end
D = inv(G'*G);
sqrt(diag(D)) %��������

%% �������洢�ռ�
output.satnav = zeros(n,8); %���ǵ���������
output.filter = zeros(n,9); %�˲����
output.bias = zeros(n,6); %��ƫ���ƽ��
output.dt = zeros(n,1); %�Ӳ�
output.df = zeros(n,1); %��Ƶ��
output.P = zeros(n,17);

%% ��ʼ�������˲���
para.dt = dt;
para.gyro0 = bias_gyro; %deg/s
para.p0 = p0;
para.v0 = [0,0,0];
para.a0 = a0 + [0,1,1]*0; %deg
para.P0_att = 1; %deg
para.P0_vel = 1; %m/s
para.P0_pos = 5; %m
para.P0_dtr = 2e-8; %s
para.P0_dtv = 3e-9; %s/s
para.P0_gyro = 0.2; %deg/s
para.P0_acc = 2e-3; %g
para.Q_gyro = sigma_gyro; %deg/s
para.Q_acc = sigma_acc; %g
para.Q_dtv = 0.01e-9; %1/s
para.Q_dg = 0.01; %deg/s/s
para.Q_da = 0.1e-3; %g/s
para.sigma_gyro = sigma_gyro; %deg/s
NF = filter_tight(para);

%% ��ʼ����
sv_9_11 = [ones(svN,1)*2, ...
           ones(svN,1)*sigma_rho^2, ...
           ones(svN,1)*sigma_rhodot^2];
for k=1:n
    % ������������
    dtr = dtr + dtv*dt; %��ǰ�Ӳ�
    sv = sv_real;
    sv(:,7) = sv(:,7) + randn(svN,1)*sigma_rho + dtr*c;
    sv(:,8) = sv(:,8) + randn(svN,1)*sigma_rhodot + dtv*c;
    
    % ���ǵ�������
    satnav = satnavSolve(sv, rp);
    
    % �����˲�
    NF.run(imu(k,:), [sv,sv_9_11]);
    dtv = dtv - NF.dtv;
    dtr = dtr - NF.dtr;
    
    % �洢���
    output.satnav(k,:) = satnav([1,2,3,7,8,9,13,14]);
    output.filter(k,:) = [NF.pos, NF.vel, NF.att];
    output.bias(k,:) = NF.bias;
    output.dt(k) = dtr;
    output.df(k) = dtv;
    P = NF.P;
    output.P(k,:) = sqrt(diag(P));
    Cnb = quat2dcm(NF.quat);
    P_angle = var_phi2angle(P(1:3,1:3), Cnb);
    output.P(k,1:3) = sqrt(diag(P_angle));
end

%% ��λ�����
r2d = 180/pi;
figure('Name','λ��')
for k=1:2
    subplot(3,1,k)
    plot(t, output.satnav(:,k))
    hold on
    grid on
    axis manual
    plot(t, output.filter(:,k), 'LineWidth',2)
    plot(t, p0(k)+output.P(:,k+6)*r2d*3, 'Color','y', 'LineStyle','--')
    plot(t, p0(k)-output.P(:,k+6)*r2d*3, 'Color','y', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end
subplot(3,1,3)
plot(t, output.satnav(:,3))
hold on
grid on
axis manual
plot(t, output.filter(:,3), 'LineWidth',2)
plot(t, p0(3)+output.P(:,9)*3, 'Color','y', 'LineStyle','--')
plot(t, p0(3)-output.P(:,9)*3, 'Color','y', 'LineStyle','--')
set(gca, 'xlim', [0,t(end)])

%% ���ٶ����
figure('Name','�ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t, output.satnav(:,k+3))
    hold on
    grid on
    axis manual
    plot(t, output.filter(:,k+3), 'LineWidth',2)
    plot(t,  output.P(:,k+3)*3, 'Color','y', 'LineStyle','--')
    plot(t, -output.P(:,k+3)*3, 'Color','y', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end

%% ����̬���
r2d = 180/pi;
figure('Name','��̬')
for k=1:3
    subplot(3,1,k)
    plot(t, output.filter(:,k+6), 'LineWidth',2)
    hold on
    grid on
    axis manual
    plot(t, a0(k)+output.P(:,k)*r2d*3, 'Color','r', 'LineStyle','--')
    plot(t, a0(k)-output.P(:,k)*r2d*3, 'Color','r', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end

%% ����������ƫ���
r2d = 180/pi;
figure('Name','������ƫ')
for k=1:3
    subplot(3,1,k)
    plot(t, imu(:,k))
    hold on
    grid on
    axis manual
    plot(t, output.bias(:,k), 'LineWidth',2)
    plot(t, bias_gyro(k)+output.P(:,k+11)*r2d*3, 'Color','y', 'LineStyle','--')
    plot(t, bias_gyro(k)-output.P(:,k+11)*r2d*3, 'Color','y', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end

%% �����ٶȼ���ƫ���
figure('Name','�Ӽ���ƫ')
for k=1:3
    subplot(3,1,k)
    plot(t, output.bias(:,k+3), 'LineWidth',2)
    hold on
    grid on
    axis manual
    plot(t, bias_acc(k)+output.P(:,k+14)/9.8*3, 'Color','r', 'LineStyle','--')
    plot(t, bias_acc(k)-output.P(:,k+14)/9.8*3, 'Color','r', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end