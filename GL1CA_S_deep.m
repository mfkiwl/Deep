%% GPS L1 C/A�����������

%%
clear
clc
fclose('all'); %�ر�֮ǰ�򿪵������ļ�

Ts = 600; %�ܴ���ʱ��,s
To = 0; %ƫ��ʱ��,s
svList = [];
p0 = [45.730952, 126.624970, 212]; %���µĳ�ʼλ��
% p0 = [38.0463, 114.4358, 100];
psi0 = 38.1; %��ʼ����,deg,191
arm = [-0.1,0,0]*1; %�˱�,IMUָ������,0.32

%% ѡ��IMU�����ļ�
[file, path] = uigetfile('*.dat;*.txt', 'ѡ��IMU�����ļ�'); %�ļ�ѡ��Ի���
if ~ischar(file)
    error('File error!')
end
imu = IMU_read([path,file]); %��IMU�����ļ�
imuN = size(imu,1); %IMU��������
gyro0 = mean(imu(1:200,2:4)); %�����ʼ������ƫ

%% ѡ��GNSS�����ļ�
valid_prefix = 'B210-SIM-'; %�ļ�����Чǰ׺
[file, path] = uigetfile('*.dat', 'ѡ��GNSS�����ļ�'); %�ļ�ѡ��Ի���
if ~ischar(file) || ~contains(valid_prefix, strtok(file,'_'))
    error('File error!')
end
data_file = [path, file]; %�����ļ�����·��,path����\

%% ��������
% ����ʵ������޸�.
msToProcess = Ts*1000; %������ʱ��
sampleOffset = To*4e6; %����ǰ���ٸ�������
sampleFreq = 4e6; %���ջ�����Ƶ��
blockSize = sampleFreq*0.001; %һ�������(1ms)�Ĳ�������

%% ��ȡ���ջ���ʼʱ��
[~, filename] = strtok(file,'_'); %�ļ���ȥ��ǰ׺ʣ�µĲ���
filetime = filename(2:16); %�ļ�ʱ��
tf = sscanf(filetime, '%4d%02d%02d_%02d%02d%02d')'; %�����ļ���ʼʱ��(����ʱ������)
tg = UTC2GPS(tf, 8); %UTCʱ��ת��ΪGPSʱ��
ta = [tg(2),0,0] + sample2dt(sampleOffset, sampleFreq); %���ջ���ʼʱ��,[s,ms,us]
ta = timeCarry(round(ta,2)); %��λ,΢�뱣��2λС��

%% ��ȡ����
% ��ָ������洢���ļ���.
almanac_file = GPS.almanac.download('~temp\almanac', tg); %��������
almanac = GPS.almanac.read(almanac_file); %������

%% ���ջ�����
% ����ʵ�������޸�.
receiver_conf.Tms = msToProcess; %���ջ�������ʱ��,ms
receiver_conf.sampleFreq = sampleFreq; %����Ƶ��,Hz
receiver_conf.blockSize = blockSize; %һ�������(1ms)�Ĳ�������
receiver_conf.blockNum = 50; %����������
receiver_conf.week = tg(1); %��ǰGPS����
receiver_conf.ta = ta; %���ջ���ʼʱ��,[s,ms,us]
receiver_conf.CN0Thr = [37,33,30,18]; %�������ֵ
receiver_conf.almanac = almanac; %����
receiver_conf.eleMask = 10; %�߶Ƚ���ֵ
receiver_conf.svList = svList; %���������б�
receiver_conf.acqTime = 2; %�������õ����ݳ���,ms
receiver_conf.acqThreshold = 1.4; %������ֵ,��߷���ڶ����ı�ֵ
receiver_conf.acqFreqMax = 5e3; %�������Ƶ��,Hz
receiver_conf.p0 = p0; %��ʼλ��,γ����
receiver_conf.dtpos = 10; %��λʱ����,ms

%% �����˲�������
para.dt = 0.01; %s,����IMU������������
para.p0 = [0,0,0];
para.v0 = [0,0,0];
para.a0 = [psi0,0,0]; %deg
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
para.Q_dg = 0.01*1; %deg/s/s
para.Q_da = 0.1e-3; %g/s
para.sigma_gyro = 0.15; %deg/s
para.arm = arm; %m
para.gyro0 = gyro0; %deg/s
if strcmp(file(1:3),'SIM')
    para.windupFlag = 0;
else
    para.windupFlag = 1;
end
% �ʼ�Ĳ���:0.15, 2, 0.01, 0.1

% 11ά�˲����õ�
% para.Q_gyro = 1.0; %deg/s
% para.Q_acc = 2e-2; %g

%% �������ջ�����
nCoV = GL1CA_S(receiver_conf);

%% Ԥ������
% ��ѡ����,������ǰ���ж�λ.
% ��ָ�������洢���ļ���.
% �����ļ����Բ�����,����ʱ���Զ�����.
% ע�͵����ʱͬʱҪע�͵�����ı�������.
ephemeris_file = ['~temp\ephemeris\',filetime,'.mat']; %�ļ���
nCoV.set_ephemeris(ephemeris_file);

%% ���ļ�,����������
fileID = fopen(data_file, 'r');
fseek(fileID, round(sampleOffset*4), 'bof'); %��ȡ�����ܳ����ļ�ָ���Ʋ���ȥ
if int64(ftell(fileID))~=int64(sampleOffset*4) %����ļ�ָ���Ƿ��ƹ�ȥ��
    error('Sample offset error!')
end
waitbar_str = ['s/',num2str(msToProcess/1000),'s']; %�������в�����ַ���
f = waitbar(0, ['0',waitbar_str]);

%% ���ջ�����
tic
for t=1:msToProcess
    if mod(t,1000)==0 %1s����
        waitbar(t/msToProcess, f, [sprintf('%d',t/1000),waitbar_str]); %���½�����
    end
    data = fread(fileID, [2,blockSize], 'int16'); %���ļ�������
    nCoV.run(data); %���ջ���������
    %---------------------------------------------------------------------%
    if nCoV.state==3 %�����ʱ,����һ�ζ�λ��Ϊ�������´ζ�λʱ���IMU����
        if isnan(nCoV.tp(1)) %��λ��tp����NaN
            ki = ki+1; %IMU������1
            if ki>imuN %IMU���ݳ���Χ
                break
            end
            nCoV.imu_input(imu(ki,1), imu(ki,2:7)); %����IMU����
        end
    elseif nCoV.state==1 %�����ջ���ʼ����ɺ���������
        ki = find(imu(:,1)>nCoV.ta*[1;1e-3;1e-6], 1); %IMU����
        if isempty(ki) || (imu(ki,1)-nCoV.ta(1))>1
            error('Data mismatch!')
        end
        nCoV.imu_input(imu(ki,1), imu(ki,2:7)); %����IMU����
        para.p0 = nCoV.pos;
        para.v0 = nCoV.vel;
        if norm(nCoV.vel)>2
            para.a0 = [atan2d(nCoV.vel(2),nCoV.vel(1)),0,0];
            nCoV.navFilter = filter_single(para); %��ʼ�������˲���
            nCoV.navFilter.motion.state0 = 1;
            nCoV.navFilter.motion.state = 1;
        else
            nCoV.navFilter = filter_single(para); %��ʼ�������˲���
        end
        %------------------------------------------------------------------
%         nCoV.navFilter = filter_single_11(para);
%         nCoV.navFilter = filter_single_arm(para);
%         nCoV.navFilter = filter_single_delay(para);
        nCoV.vectorMode = 2; %����ʸ������ģʽ
        nCoV.channel_vector; %ͨ���л�ʸ�����ٻ�·
        nCoV.state = 3; %���ջ����������
    end
    %---------------------------------------------------------------------%
end
nCoV.clean_storage;
nCoV.get_result;
toc

%% �ر��ļ�,�رս�����
fclose(fileID);
close(f);

%% ��������
% ��ǰ���Ԥ��������Ӧ.
nCoV.save_ephemeris(ephemeris_file);

%% �������
clearvars -except data_file receiver_conf nCoV tf p0 imu

%% ����������ͼ
nCoV.interact_constellation;

%% ������
save('~temp\result\result.mat')