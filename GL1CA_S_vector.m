%% GPS L1 C/A������ʸ������

%%
clear
clc
fclose('all'); %�ر�֮ǰ�򿪵������ļ�

Ts = 60; %�ܴ���ʱ��,s
To = 0; %ƫ��ʱ��,s
svList = [];
p0 = [45.730952, 126.624970, 212]; %���µĳ�ʼλ��

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
receiver_conf.CN0Thr = [37,33,21,18]; %�������ֵ,�ز��ָ���ֵС,��֤��·�Ƿ��������Լ��ָ�
receiver_conf.almanac = almanac; %����
receiver_conf.eleMask = 10; %�߶Ƚ���ֵ
receiver_conf.svList = svList; %���������б�
receiver_conf.acqTime = 2; %�������õ����ݳ���,ms
receiver_conf.acqThreshold = 1.4; %������ֵ,��߷���ڶ����ı�ֵ
receiver_conf.acqFreqMax = 5e3; %�������Ƶ��,Hz
receiver_conf.p0 = p0; %��ʼλ��,γ����
receiver_conf.dtpos = 50; %��λʱ����,ms

%% �����˲�������
para.dt = receiver_conf.dtpos / 1000;
para.p0 = [0,0,0];
para.v0 = [0,0,0];
para.P0_pos = 5; %m
para.P0_vel = 1; %m/s
para.P0_acc = 1; %m/s^2
para.P0_dtr = 2e-8; %s
para.P0_dtv = 3e-9; %s/s
para.Q_pos = 0;
para.Q_vel = 0;
para.Q_acc = 100;
para.Q_dtr = 0;
para.Q_dtv = 1e-9;

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
    if nCoV.state==1 %�����ջ���ʼ����ɺ����ʸ������
        para.p0 = nCoV.pos;
        nCoV.navFilter = filter_sat(para); %��ʼ�������˲���
        nCoV.vectorMode = 3; %����ʸ������ģʽ
        nCoV.channel_vector; %ͨ���л�ʸ�����ٻ�·
        nCoV.state = 4; %���ջ�����ʸ������
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
clearvars -except data_file receiver_conf nCoV tf p0

%% ����������ͼ
nCoV.interact_constellation;

%% ������
save('~temp\result\result.mat')