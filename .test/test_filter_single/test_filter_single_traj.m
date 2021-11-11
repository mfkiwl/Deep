%% ���Ե����ߵ����˲���(ʹ�ù켣,������������)

%%
clear
clc
% rng(1)

%% ���ò���
t0 = [2020,7,27,11,16,14]; %��ʼʱ��
trajName = 'traj004'; %�켣�ļ���
dti = 0.01; %IMU��������,s
dtg = 0.01; %GPS��������,s
gyroBias = [0.1, 0.2, 0.3] *1; %��������ƫ,deg/s
accBias = [-2, 2, -3]*0.01 *1; %���ٶȼ���ƫ,m/s^2
gyroSigma = 0.03 *1; %������������׼��,deg/s
accSigma = 0.01 *1; %���ٶȼ�������׼��,m/s^2
sigma_rho = 3; %m
sigma_rhodot = 0.04; %m/s
dtr0 = 1e-8; %��ʼ�Ӳ�,s
dtv = 3e-9; %��Ƶ��,s/s
c = 299792458;

%% ���ع켣
load(['~temp\traj\',trajName,'.mat'])
m = dti / trajGene_conf.dt; %ȡ��������
traj = traj(1:m:end,:);
traj(1,:) = []; %ɾ��һ��

%% �켣��Ӹ˱�
arm0 = [0,0,0];
if any(arm0)
    traj = traj_addarm(traj, arm0);
end

%% ��������,������ͼ
t0g = UTC2GPS(t0, 8);
almanac_file = GPS.almanac.download('~temp\almanac', t0g); %��������
almanac = GPS.almanac.read(almanac_file); %������
svID = almanac(:,1);
almanac(:,1:4) = [];
ax = GPS.constellation('~temp\almanac', t0, 8, traj(1,7:9));

%% IMU���ݼ�����
n = size(traj,1);
imu = traj(:,13:18);
imu(:,1:3) = imu(:,1:3) + ones(n,1)*gyroBias + randn(n,3)*gyroSigma;
imu(:,4:6) = imu(:,4:6) + ones(n,1)*accBias + randn(n,3)*accSigma;
imu(:,1:3) = imu(:,1:3)/180*pi; %rad/s

%% �˲�������
para.dt = dti; %s
para.p0 = traj(1,7:9);
para.v0 = traj(1,10:12);
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
para.arm = arm0; %m
para.gyro0 = gyroBias; %deg/s
para.windupFlag = 0;
NF = filter_single(para);

if norm(para.v0)>2
    NF.motion.state0 = 1;
    NF.motion.state = 1;
end

%% ������
output.satnav = NaN(n,14);
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
        tg = t0g + [0, k*dti]; %��ǰGPSʱ��
        pos0 = traj(k,7:9); %��ǰλ��
        vel0 = traj(k,10:12); %��ǰ�ٶ�
        rsvs = rsvs_almanac(almanac, tg); %������������λ���ٶ�
        [azi, ele] = aziele_xyz(rsvs(:,1:3), pos0); %�����������Ǹ߶ȽǷ�λ��
        selIndex = find(ele>10); %��ѡ���ǵ��к�
        selID = svID(selIndex); %��ѡ���ǵ�ID��
        svN = length(selIndex); %���Ǹ���
        rs = rsvs(selIndex,1:3);
        vs = rsvs(selIndex,4:6);
        [rho, rhodot, rspu, ~] = rho_rhodot_cal_geog(rs, vs, pos0, vel0); %������Ծ��������ٶ�
        rho = rho + dtr*c + randn(svN,1)*sigma_rho;
        rhodot = rhodot./(1-sum(vs.*rspu,2)/c) + dtv*c + randn(svN,1)*sigma_rhodot;
        sv = [rs, vs, rho, rhodot, ones(svN,1)*sigma_rho^2, ones(svN,1)*sigma_rhodot^2];
        %------------------------------------------------------------------
        output.satnav(k,:) = satnavSolve(sv, NF.rp); %���ǵ�������
%         output.satnav(k,:) = satnavSolveWeighted(sv, NF.rp);
        NF.run(imu_k, sv, true(svN,1), true(svN,1));
    else %û����������
        NF.run(imu_k);
    end
    
    %----�˱�����
    Cnb = quat2dcm(NF.quat);
    Cen = dcmecef2ned(NF.pos(1), NF.pos(2));
    Ceb = Cnb*Cen;
    wb = imu_k(1:3) - NF.bias(1:3); %���ٶ�,rad/s
    r_arm = NF.arm*Ceb;
    v_arm = cross(wb,NF.arm)*Ceb;
    rp = NF.rp + r_arm;
    vp = NF.vp + v_arm;
    pos = ecef2lla(rp);
    vel = vp*Cen';
    
    %----�洢���
    output.pos(k,:) = pos;
    output.vel(k,:) = vel;
    output.att(k,:) = NF.att;
    output.clk(k,:) = [NF.dtr, NF.dtv];
    output.bias(k,:) = NF.bias;
    P = NF.P;
    output.P(k,:) = sqrt(diag(P));
    P_angle = var_phi2angle(P(1:3,1:3), Cnb);
    output.P(k,1:3) = sqrt(diag(P_angle));
    output.imu(k,:) = imu_k;
end

%% ��ͼ
plot_filter_single;