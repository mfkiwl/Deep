%% GPS L1 C/A�����������

%%
clear
clc
fclose('all'); %�ر�֮ǰ�򿪵������ļ�

%% ѡ��IMU�����ļ�
imu = IMU_read(0);

%% ѡ��GNSS�����ļ�
valid_prefix = 'B210-'; %�ļ�����Чǰ׺
[file, path] = uigetfile('*.dat', 'ѡ��GNSS�����ļ�'); %�ļ�ѡ��Ի���
if ~ischar(file) || ~contains(valid_prefix, strtok(file,'_'))
    error('File error!')
end
data_file = [path, file]; %�����ļ�����·��,path����\

% data_file = 'C:\Users\longt\Desktop\B210_20190823_194010_ch1.dat'; %ָ���ļ�,���ڲ���

%% ��������
% ����ʵ������޸�.
msToProcess = 60*1000; %������ʱ��
sampleOffset = 0*4e6; %����ǰ���ٸ�������
sampleFreq = 4e6; %���ջ�����Ƶ��
blockSize = sampleFreq*0.001; %һ�������(1ms)�Ĳ�������
p0 = [45.730952, 126.624970, 212]; %��ʼλ��,�����ر�ȷ

%% ��ȡ���ջ���ʼʱ��
tf = sscanf(data_file((end-22):(end-8)), '%4d%02d%02d_%02d%02d%02d')'; %�����ļ���ʼʱ��(����ʱ������)
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
receiver_conf.blockNum = 40; %����������
receiver_conf.week = tg(1); %��ǰGPS����
receiver_conf.ta = ta; %���ջ���ʼʱ��,[s,ms,us]
receiver_conf.p0 = p0; %��ʼλ��,γ����
receiver_conf.almanac = almanac; %����
receiver_conf.eleMask = 10; %�߶Ƚ���ֵ
receiver_conf.svList = []; %���������б�[10,15,20,24]
receiver_conf.acqTime = 2; %�������õ����ݳ���,ms
receiver_conf.acqThreshold = 1.4; %������ֵ,��߷���ڶ����ı�ֵ
receiver_conf.acqFreqMax = 5e3; %�������Ƶ��,Hz
receiver_conf.dtpos = 10; %��λʱ����,ms

%% �������ջ�����
nCoV = GL1CA_S(receiver_conf);

%% Ԥ������
% ��ѡ����,������ǰ���ж�λ.
% ��ָ�������洢���ļ���.
% �����ļ����Բ�����,����ʱ���Զ�����.
% ע�͵����ʱͬʱҪע�͵�����ı�������.
ephemeris_file = ['~temp\ephemeris\',data_file((end-22):(end-8)),'.mat']; %�ļ���
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
    % �����ģʽ�л�,IMU��������
    if nCoV.state==2
        % ���������ģʽ��,����һ�ζ�λ��Ϊ�������´ζ�λʱ���IMU����
        if isnan(nCoV.tp(1)) %��λ��tp����NaN
            ki = ki+1; %IMU������1
            nCoV.imu_input(imu(ki,1), imu(ki,2:7)); %����IMU����
        end
    elseif nCoV.state==1
        % �����ջ���ʼ����ɺ���������ģʽ
        ki = find(imu(:,1)>nCoV.ta*[1;1e-3;1e-6], 1); %IMU����
        if isempty(ki) || (imu(ki,1)-nCoV.ta(1))>1
            error('Data mismatch!')
        end
        nCoV.imu_input(imu(ki,1), imu(ki,2:7)); %����IMU����
        nCoV.enter_deep; %���������ģʽ
    end
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
clearvars -except data_file receiver_conf nCoV almanac_path tf p0 imu

%% ����������ͼ
nCoV.interact_constellation;

%% ����

% nCoV.print_all_log; %��ӡͨ����־
% nCoV.plot_all_trackResult; %��ʾ���ٽ��
% GPS.visibility('~temp\almanac', tf, 8, p0, 1); %��ʾ��ǰ�ɼ�����һ��ʱ��Ĺ켣

%% ������
save('~temp\result.mat')