% IMU��������(ʹ��Matlab�������е�IMUģ��)

clearvars -except imuGene_conf imuGene_GUIflag
clc

%% IMU������������Ԥ��ֵ
% ʹ��GUIʱ�ⲿ������imuGene_conf,����imuGene_GUIflag��1
if ~exist('imuGene_GUIflag','var') || imuGene_GUIflag~=1
    imuGene_conf.startTime = [2020,7,27,11,16,14]; %���ݿ�ʼʱ��
    imuGene_conf.zone = 8; %ʱ��
    imuGene_conf.dt = 0.01; %IMU��������,s
    imuGene_conf.gyroBias = [0.1,0.2,0.3]*1; %��������ƫ,deg/s
    imuGene_conf.gyroInstability = 2.5/3600; %��������ƫ�ȶ���,deg/s
    imuGene_conf.gyroNoise = 0.15/60; %�����������ܶ�,deg/s/sqrt(Hz)
    imuGene_conf.accBias = [-2,2,-3]*0.01*1; %���ٶȼ���ƫ,m/s^2
    imuGene_conf.accInstability = 13e-6*10; %���ٶȼ���ƫ�ȶ���,m/s^2
    imuGene_conf.accNoise = 0.037/60; %���ٶȼ������ܶ�,m/s^2/sqrt(Hz)
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
gyroInstability = imuGene_conf.gyroInstability; %��������ƫ�ȶ���,deg/s
gyroNoise = imuGene_conf.gyroNoise; %�����������ܶ�,deg/s/sqrt(Hz)
accBias = imuGene_conf.accBias; %���ٶȼ���ƫ,m/s^2
accInstability = imuGene_conf.accInstability; %���ٶȼ���ƫ�ȶ���,m/s^2
accNoise = imuGene_conf.accNoise; %���ٶȼ������ܶ�,m/s^2/sqrt(Hz)
trajName = imuGene_conf.trajName; %�켣��

%% ���ɴ���������
paramsG = gyroparams;
paramsG.ConstantBias = gyroBias /180*pi; %rad/s
paramsG.BiasInstability = gyroInstability /180*pi; %rad/s
paramsG.NoiseDensity = gyroNoise /180*pi; %rad/s/sqrt(Hz)
paramsA = accelparams;
paramsA.ConstantBias = accBias; %m/s^2
paramsA.BiasInstability = accInstability; %m/s^2
paramsA.NoiseDensity = accNoise; %m/s^2/sqrt(Hz)
IMU_obj = imuSensor('accel-gyro');
IMU_obj.SampleRate = 1/dt;
IMU_obj.Accelerometer = paramsA;
IMU_obj.Gyroscope = paramsG;

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
[imu(:,5:7), imu(:,2:4)] = IMU_obj(-imu(:,5:7), imu(:,2:4)/180*pi);
imu(:,2:4) = imu(:,2:4) /pi*180;
imu(:,7) = imu(:,7) - 9.81;

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