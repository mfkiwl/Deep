%% GPS L1 C/A & BDS B1C�����߽��ջ�����

%%
clear
clc
fclose('all'); %�ر�֮ǰ�򿪵������ļ�

%% ѡ��GNSS�����ļ�
% valid_prefix = 'B210-'; %�ļ�����Чǰ׺
% [file, path] = uigetfile('*.dat', 'ѡ��GNSS�����ļ�'); %�ļ�ѡ��Ի���
% if ~ischar(file) || ~contains(valid_prefix, strtok(file,'_'))
%     error('File error!')
% end
% data_file = [path, file]; %�����ļ�����·��,path����\

% data_file = 'C:\Users\longt\Desktop\B210_20190823_194010_ch1.dat'; %ָ���ļ�,���ڲ���
data_file = 'C:\Users\longt\Desktop\GNSS data\B210_20200727_111615_ch1.dat';

%% ��������
% ����ʵ������޸�.
msToProcess = 10*1000; %������ʱ��
sampleOffset = 0*4e6; %����ǰ���ٸ�������
sampleFreq = 4e6; %���ջ�����Ƶ��
blockSize = sampleFreq*0.001; %һ�������(1ms)�Ĳ�������
p0 = [45.730952, 126.624970, 212]; %��ʼλ��,�����ر�ȷ

%% ��ȡ���ջ���ʼʱ��
tf = sscanf(data_file((end-22):(end-8)), '%4d%02d%02d_%02d%02d%02d')'; %�����ļ���ʼʱ��(����ʱ������)
% GPSʱ
tg = UTC2GPS(tf, 8); %UTCʱ��ת��ΪGPSʱ��,��+��
tag = [tg(2),0,0] + sample2dt(sampleOffset, sampleFreq); %���ջ���ʼʱ��,[s,ms,us]
tag = timeCarry(round(tag,2)); %��λ,΢�뱣��2λС��
% ����ʱ
tb = UTC2BDT(tf, 8); %UTCʱ��ת��ΪBDTʱ��,��+��
tab = [tb(2),0,0] + sample2dt(sampleOffset, sampleFreq);
tab = timeCarry(round(tab,2));

%% ��ȡ����
% ��ָ������洢���ļ���.
almanac_file_GPS = GPS.almanac.download('~temp\almanac', tg); %��������
almanac_GPS = GPS.almanac.read(almanac_file_GPS); %������
date = sprintf('%4d-%02d-%02d', tf(1),tf(2),tf(3)); %��ǰ����
almanac_file_BDS = BDS.almanac.download('~temp\almanac', date); %��������
almanac_BDS = BDS.almanac.read(almanac_file_BDS); %������
index = ismember(almanac_BDS(:,1), [19:30,32:46]);
almanac_BDS = almanac_BDS(index,:); %ֻҪ�����������ǵ�����

%% ���ջ�����
% ����ʵ�������޸�.
receiver_conf.Tms = msToProcess; %���ջ�������ʱ��,ms
receiver_conf.sampleFreq = sampleFreq; %����Ƶ��,Hz
receiver_conf.blockSize = blockSize; %һ�������(1ms)�Ĳ�������
receiver_conf.blockNum = 100; %����������
receiver_conf.GPSflag = 1; %�Ƿ�����GPS
receiver_conf.BDSflag = 1; %�Ƿ����ñ���
%-------------------------------------------------------------------------%
receiver_conf.GPS.week = tg(1); %��ǰGPS����
receiver_conf.GPS.ta = tag; %���ջ���ʼGPSʱ��,[s,ms,us]
receiver_conf.GPS.almanac = almanac_GPS; %����
receiver_conf.GPS.eleMask = 10; %�߶Ƚ���ֵ
receiver_conf.GPS.svList = []; %���������б�,[10,15,20,24]
receiver_conf.GPS.acqTime = 2; %�������õ����ݳ���,ms
receiver_conf.GPS.acqThreshold = 1.4; %������ֵ,��߷���ڶ����ı�ֵ
receiver_conf.GPS.acqFreqMax = 5e3; %�������Ƶ��,Hz
%-------------------------------------------------------------------------%
receiver_conf.BDS.week = tb(1); %��ǰ��������
receiver_conf.BDS.ta = tab; %���ջ���ʼBDSʱ��,[s,ms,us]
receiver_conf.BDS.almanac = almanac_BDS; %����
receiver_conf.BDS.eleMask = 10; %�߶Ƚ���ֵ
receiver_conf.BDS.svList = [19,20,29,35,38,40,44]; %���������б�,[19,20,29,35,38,40,44]
receiver_conf.BDS.acqThreshold = 1.4; %������ֵ,��߷���ڶ����ı�ֵ
receiver_conf.BDS.acqFreqMax = 5e3; %�������Ƶ��,Hz
%-------------------------------------------------------------------------%
receiver_conf.p0 = p0; %��ʼλ��,γ����
receiver_conf.dtpos = 10; %��λʱ����,ms

%% �������ջ�����
nCoV = GL1CA_BB1C_S(receiver_conf);

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
end
nCoV.clean_storage;
toc

%% �ر��ļ�,�رս�����
fclose(fileID);
close(f);

%% �������
clearvars -except data_file receiver_conf nCoV tf p0

%% ����������ͼ
nCoV.interact_constellation;