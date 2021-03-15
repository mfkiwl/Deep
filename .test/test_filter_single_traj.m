%% ���Ե����ߵ����˲���(ʹ�ù켣)

%%
clear
clc

%% ���ò���
dt = 0.01; %IMU��������,s
gyroBias = [0.1,0.2,0.3]*1; %��������ƫ,deg/s
accBias = [-2,2,-3]*0.01*1; %���ٶȼ���ƫ,m/s^2
gyroSigma = 0.03*1; %������������׼��,deg/s
accSigma = 0.01*1; %���ٶȼ�������׼��,m/s^2
trajName = 'traj008'; %�켣�ļ���
sigma_rho = 3; %m
sigma_rhodot = 0.04; %m/s
dtr = 1e-8; %��ʼ�Ӳ�,s
dtv = 3e-9; %��Ƶ��,s/s
c = 299792458;
arm = [0,0,0]; %�˱�,IMUָ������
gyro0 = gyroBias; %��ʼ������ƫ

%% ���ع켣
load(['~temp\traj\',trajName,'.mat'])
m = dt / trajGene_conf.dt; %ȡ��������
traj = traj(1:m:end,:);
traj(1,:) = []; %ɾ��һ��

%% IMU���ݼ�����
n = size(traj,1);
imu = traj(:,13:18);
imu(:,1:3) = imu(:,1:3) + ones(n,1)*gyroBias + randn(n,3)*gyroSigma;
imu(:,4:6) = imu(:,4:6) + ones(n,1)*accBias + randn(n,3)*accSigma;
imu(:,1:3) = imu(:,1:3)/180*pi; %rad/s

%% ������Ϣ
% ��һ��Ϊ��λ��,�ڶ���Ϊ�߶Ƚ�,deg
sv_info = [  0, 45;
            58, 80;
           100, 49;
           146, 34;
           186, 78;
           213, 43;
           255, 15;
           310, 20];
rho = 20000000; %���ǵ����ջ��ľ���,m
svN = size(sv_info,1); %���Ǹ���
sv = zeros(svN,10);
sv(:,9) = sigma_rho^2;
sv(:,10) = sigma_rhodot^2;

%% ����λ��(�̶�)
rp = lla2ecef(traj(1,7:9));
Cen = dcmecef2ned(traj(1,7), traj(1,8));
for k=1:svN
    e = [-cosd(sv_info(k,2))*cosd(sv_info(k,1)), ...
         -cosd(sv_info(k,2))*sind(sv_info(k,1)), ...
          sind(sv_info(k,2))]; %����ָ����ջ��ĵ�λʸ��
    rsp = e * rho; %����ָ����ջ���λ��ʸ��
    sv(k,1:3) = rp - (rsp*Cen); %����λ��
end

%% �˲�������
para.dt = dt; %s
para.p0 = traj(1,7:9);
para.v0 = [0,0,0];
para.a0 = traj(1,4:6); %deg
para.P0_att = 1; %deg
para.P0_vel = 1; %m/s
para.P0_pos = 15; %m
para.P0_dtr = 5e-8; %s
para.P0_dtv = 3e-9; %s/s
para.P0_gyro = 0.2; %deg/s
para.P0_acc = 2e-3; %g
para.Q_gyro = 0.2; %deg/s
para.Q_acc = 2e-3; %g
para.Q_dtv = 0.01e-9; %1/s
para.Q_dg = 0.01; %deg/s/s
para.Q_da = 0.1e-3; %g/s
para.sigma_gyro = 0.03; %deg/s
para.arm = arm; %m
para.gyro0 = gyro0; %deg/s
para.windupFlag = 0;
NF = filter_single(para);

%% ������
output.satnav = zeros(n,14);
output.pos = zeros(n,3);
output.vel = zeros(n,3);
output.att = zeros(n,3);
output.clk = zeros(n,2);
output.bias = zeros(n,6);
output.P = zeros(n,20);
output.imu = zeros(n,6);
output.arm = zeros(n,3);

%% ����
for k=1:n
    % ������������
    dtr = dtr + dtv*dt; %��ǰ�Ӳ�
    Cen = dcmecef2ned(traj(k,7), traj(k,8));
    for m=1:svN
        rsp = traj(k,1:3) - sv(m,1:3);
        rho = norm(rsp);
        rspu = rsp / rho;
        vsp = traj(k,10:12)*Cen;
        rhodot = vsp * rspu';
        sv(m,7) = rho;
        sv(m,8) = rhodot;
    end
    sv(:,7) = sv(:,7) + randn(svN,1)*sigma_rho + dtr*c;
    sv(:,8) = sv(:,8) + randn(svN,1)*sigma_rhodot + dtv*c;
    index = true(svN,1);
    
    % ���ǵ�������
    satnav = satnavSolveWeighted(sv(index,:), NF.rp);
    
    % �����˲�
    IMU = imu(k,:); %��ȡIMU����
    NF.run(IMU, sv, index, index);
    
    % �˱�����
    Cnb = quat2dcm(NF.quat);
    Cen = dcmecef2ned(NF.pos(1), NF.pos(2));
    wb = IMU(1:3) - NF.bias(1:3); %���ٶ�,rad/s
    r_arm = arm*Cnb*Cen;
    v_arm = cross(wb,arm)*Cnb*Cen;
    rp = NF.rp + r_arm;
    vp = NF.vp + v_arm;
    pos = ecef2lla(rp);
    vel = vp*Cen';
    
    % �洢���
    output.satnav(k,:) = satnav;
    output.pos(k,:) = pos;
    output.vel(k,:) = vel;
    output.att(k,:) = NF.att;
    output.clk(k,:) = [NF.dtr, NF.dtv];
    output.bias(k,:) = NF.bias;
    P = NF.P;
    output.P(k,1:size(P,1)) = sqrt(diag(P));
    P_angle = var_phi2angle(P(1:3,1:3), Cnb);
    output.P(k,1:3) = sqrt(diag(P_angle));
    output.imu(k,:) = IMU;
    output.arm(k,:) = NF.arm;
end

%% ��λ�����
t = (1:n)'*dt;
figure('Name','λ��')
for k=1:3
    subplot(3,1,k)
    plot(t,[output.satnav(:,k),output.pos(:,k)])
    grid on
end

%% ���ٶ����
figure('Name','�ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t,[output.satnav(:,k+6),output.vel(:,k)])
    grid on
end

%% ����̬���
r2d = 180/pi;
figure('Name','��̬')
subplot(3,1,1)
plot(t,attContinuous(output.att(:,1)), 'LineWidth',0.5)
grid on
subplot(3,1,2)
plot(t,output.att(:,2), 'LineWidth',0.5)
hold on
grid on
axis manual
plot(t, output.P(:,2)*r2d*3, 'LineStyle','--', 'Color','r')
plot(t,-output.P(:,2)*r2d*3, 'LineStyle','--', 'Color','r')
subplot(3,1,3)
plot(t,output.att(:,3), 'LineWidth',0.5)
hold on
grid on
axis manual
plot(t, output.P(:,3)*r2d*3, 'LineStyle','--', 'Color','r')
plot(t,-output.P(:,3)*r2d*3, 'LineStyle','--', 'Color','r')

%% ���Ӳ���Ƶ��
figure('Name','�Ӳ���Ƶ��')
subplot(2,1,1)
plot(t,[output.satnav(:,13),output.clk(:,1)])
grid on
subplot(2,1,2)
plot(t,[output.satnav(:,14),output.clk(:,2)])
grid on

%% ����������ƫ���
r2d = 180/pi;
figure('Name','������ƫ(deg/s)')
for k=1:3
    subplot(3,1,k)
    plot(t,[output.imu(:,k),output.bias(:,k)]*r2d)
    grid on
    hold on
%     plot(t,gyroBias(k)+output.P(:,k+11)*r2d*3, 'LineStyle','--', 'Color','r')
%     plot(t,gyroBias(k)-output.P(:,k+11)*r2d*3, 'LineStyle','--', 'Color','r')
    set(gca, 'ylim', [-1,1])
end

%% �����ٶȼ���ƫ���
figure('Name','�Ӽ���ƫ(m/s^2)')
for k=1:3
    subplot(3,1,k)
    plot(t,output.bias(:,k+3), 'LineWidth',0.5)
    axis manual
    hold on
    grid on
    plot(t,accBias(k)+output.P(:,k+14)*3, 'LineStyle','--', 'Color','r')
    plot(t,accBias(k)-output.P(:,k+14)*3, 'LineStyle','--', 'Color','r')
end