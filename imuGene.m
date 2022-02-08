% IMU��������(ֻ�Ӱ�����)

clearvars -except imuGene_conf imuGene_GUIflag
clc

rands_gyro = RandStream('mt19937ar', 'Seed',100, 'NormalTransform','Ziggurat');
rands_acc  = RandStream('mt19937ar', 'Seed',200, 'NormalTransform','Ziggurat');

%% IMU������������Ԥ��ֵ
% ʹ��GUIʱ�ⲿ������imuGene_conf,����imuGene_GUIflag��1
if ~exist('imuGene_GUIflag','var') || imuGene_GUIflag~=1
    imuGene_conf.startTime = [2020,7,27,11,16,14]; %���ݿ�ʼʱ��
    imuGene_conf.zone = 8; %ʱ��
    imuGene_conf.dt = 0.01; %IMU��������,s
    imuGene_conf.gyroBias = [0.1,0.2,0.3]*1; %��������ƫ,deg/s
    imuGene_conf.accBias = [-2,2,-3]*0.01*1; %���ٶȼ���ƫ,m/s^2
    imuGene_conf.gyroSigma = 0.03*1; %������������׼��,deg/s
    imuGene_conf.accSigma = 0.01*1; %���ٶȼ�������׼��,m/s^2
    imuGene_conf.trajName = 'traj004'; %�켣��
end
if exist('imuGene_GUIflag','var')
    imuGene_GUIflag = 0;
end

%% ����
startTime = imuGene_conf.startTime; %���ݿ�ʼʱ��
zone = imuGene_conf.zone; %ʱ��
dt = imuGene_conf.dt; %IMU��������,s
gyroBias = imuGene_conf.gyroBias; %��������ƫ,deg/s
accBias = imuGene_conf.accBias; %���ٶȼ���ƫ,m/s^2
gyroSigma = imuGene_conf.gyroSigma; %������������׼��,deg/s
accSigma = imuGene_conf.accSigma; %���ٶȼ�������׼��,m/s^2
trajName = imuGene_conf.trajName; %�켣��

%% ���ع켣
load(['~temp\traj\',trajName,'.mat'])

%% �����������Ƿ�ƥ��
if mod(dt/trajGene_conf.dt,1)~=0
    error('Sample time mismatch!')
end

%% ���ݿ�ʼʱ��
startTime_gps = UTC2GPS(startTime, zone); %GPSʱ��
tow = startTime_gps(2); %������

%% ������
m = dt / trajGene_conf.dt; %ȡ��������
n = (size(traj,1)-1)/m + 1; %IMU���ݸ���
imu = [tow+(0:n-1)'*dt, traj(1:m:end,13:18)]; %�ӹ켣��ȡ���ٶȺͼ��ٶ�
imu(:,2:4) = imu(:,2:4) + ones(n,1)*gyroBias + randn(rands_gyro,n,3)*gyroSigma;
imu(:,5:7) = imu(:,5:7) + ones(n,1)*accBias + randn(rands_acc,n,3)*accSigma;
% imu(:,1) = imu(:,1) + 0.003; %ģ��ʱ��

%% �����ļ�
startTime_str = sprintf('%4d%02d%02d_%02d%02d%02d', startTime);
fileID = fopen(['~temp\data\IMU_',startTime_str,'_',trajName(end-2:end),'.txt'], 'w');
for k=1:n
    fprintf(fileID, '%10.3f %13.6f %13.6f %13.6f %10.3f %10.3f %10.3f\r\n' ,imu(k,:));
end
fclose(fileID);

%% �������
clearvars -except traj imu imuGene_conf

%% ��ͼ
imuGene_plot;