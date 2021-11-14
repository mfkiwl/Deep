%% ����˫���ߵ����˲���(���ջ���ֹ,���Ǿ�ֹ)

%%
clear
clc
% rng(1)

%% ���ò���
T = 100; %��ʱ��
dti = 0.01; %IMU��������,s
dtg = 0.01; %GPS��������,s
gyroBias = [0.2, 0, 0.6] *1; %��������ƫ,deg/s
accBias = [1, 0, 2]*0.01 *1; %���ٶȼ���ƫ,m/s^2
gyroSigma = 0.15 *1; %������������׼��,deg/s
accSigma = 0.015 *1; %���ٶȼ�������׼��,m/s^2
base = [1.3, 0, 0]; %����ʸ��
sigma_rho = 3; %m
sigma_rhodot = 0.1; %m/s
sigma_phase = 0.8e-3; %m
dtr0 = 1e-8; %��ʼ�Ӳ�,s
dtv = 3e-9; %��Ƶ��,s/s
c = 299792458;

%% ���ջ�λ�ú���̬
p0 = [46, 126, 200];
rp = lla2ecef(p0);
a0 = [50, 0, 0]; %deg
n = T / dti;
traj = zeros(n,12);
traj(:,7:9) = ones(n,1)*p0;
traj(:,4:6) = ones(n,1)*a0;

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
acc = (Cnb*[0;0;-gravitywgs84(p0(3),p0(1))])'; %��ʵ���ٶ�,m/s^2
imu = zeros(n,6);
imu(:,1:3) = ones(n,1)*gyroBias*d2r + ...
             randn(n,3)*gyroSigma*d2r; %rad/s
imu(:,4:6) = ones(n,1)*acc + ...
             ones(n,1)*accBias + ...
             randn(n,3)*accSigma; %m/s^2

%% ��������λ���ٶ�
svN = size(sv_info,1); %���Ǹ���
sv_real = zeros(svN,8);
phase = zeros(svN,1);
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
    phase(k) = base*Cnb*e';
end
E = G(:,1:3);
D = inv(G'*G);
sqrt(diag(D)) %��������

%% �˲�������
para.dt = dti; %s
para.p0 = p0;
para.v0 = [0,0,0];
para.a0 = a0; %deg
para.P0_att = 1; %deg
para.P0_vel = 1; %m/s
para.P0_pos = 5; %m
para.P0_dtr = 2e-8; %s
para.P0_dtv = 3e-9; %s/s
para.P0_gyro = 0.2; %deg/s
para.P0_acc = 2e-3; %g
para.Q_gyro = gyroSigma; %deg/s
para.Q_acc = accSigma/9.8; %g
para.Q_dtv = 0.03e-9; %1/s
para.Q_dg = 0.01; %deg/s/s
para.Q_da = 0.1e-3; %g/s
para.sigma_gyro = gyroSigma; %deg/s
para.arm = [0,0,0]; %m
para.gyro0 = gyroBias; %deg/s
para.windupFlag = 0;
para.base = base;
NF = filter_double(para);

%% ������
output.satnav = NaN(n,14);
output.satatt = NaN(n,6);
output.pos = zeros(n,3);
output.vel = zeros(n,3);
output.att = zeros(n,3);
output.clk = zeros(n,2);
output.bias = zeros(n,6);
output.P = zeros(n,17);
output.imu = zeros(n,6);

%% ����
M = dtg / dti; %����GPS��������
m = 0;
for k=1:n
    %----IMU����
    imu_k = imu(k,:);
    
    %----����
    m = m+1;
    if m==M %����������
        m = 0;
        %----������������---------------------------------------------------
        dtr = dtr0 + dtv*k*dti; %��ǰ�Ӳ�
        sv = [sv_real, ones(svN,1)*sigma_rho^2, ones(svN,1)*sigma_rhodot^2, ...
              phase, ones(svN,1)*sigma_phase^2];
        sv(:,7) = sv(:,7) + dtr*c + randn(svN,1)*sigma_rho;
        sv(:,8) = sv(:,8) + dtv*c + randn(svN,1)*sigma_rhodot;
        sv(:,11) = sv(:,11) + randn(svN,1)*sigma_phase;
        %------------------------------------------------------------------
        output.satnav(k,:) = satnavSolve(sv, NF.rp); %���ǵ�������
%         x = (E'*E)\(E'*sv(:,11));
%         output.satatt(k,1) = atan2d(x(2),x(1));
%         output.satatt(k,2) = -asind(x(3)/norm(x));
%         output.satatt(k,3:5) = x';
        x = (G'*G)\(G'*sv(:,11));
        output.satatt(k,1) = atan2d(x(2),x(1));
        output.satatt(k,2) = -asind(x(3)/norm(x(1:3)));
        output.satatt(k,3:6) = x';
        %------------------------------------------------------------------
        NF.run(imu_k, sv, true(svN,1), true(svN,1), true(svN,1));
    else %û����������
        NF.run(imu_k);
    end
    
    %----�洢���
    output.pos(k,:) = NF.pos;
    output.vel(k,:) = NF.vel;
    output.att(k,:) = NF.att;
    output.clk(k,:) = [NF.dtr, NF.dtv];
    output.bias(k,:) = NF.bias;
    P = NF.P;
    output.P(k,:) = sqrt(diag(P));
    Cnb = quat2dcm(NF.quat);
    P_angle = var_phi2angle(P(1:3,1:3), Cnb);
    output.P(k,1:3) = sqrt(diag(P_angle));
    output.imu(k,:) = imu_k;
end

%% ��ͼ
plot_filter_double;