% GPS L1 C/A�����߽��ջ�����

clear
clc
fclose('all'); %�ر�֮ǰ�򿪵������ļ�

%% ѡ��GNSS�����ļ�
% default_path = fileread('.\~temp\path_data.txt'); %�����ļ�����Ĭ��·��
% [file, path] = uigetfile([default_path,'\*.dat'], 'ѡ��GNSS�����ļ�'); %�ļ�ѡ��Ի���
% if file==0 %ȡ��ѡ��,file����0,path����0
%     disp('Invalid file!');
%     return
% end
% if strcmp(file(1:4),'B210')==0
%     error('File error!');
% end
% data_file = [path, file]; %�����ļ�����·��,path����\

data_file = 'C:\Users\longt\Desktop\B210_20190823_194010_ch1.dat'; %ָ���ļ�,���ڲ���

%% ��������(*)
msToProcess = 40*1000; %������ʱ��
sampleOffset = 0*4e6; %����ǰ���ٸ�������
sampleFreq = 4e6; %���ջ�����Ƶ��
blockSize = sampleFreq*0.001; %һ�������(1ms)�Ĳ�������
p0 = [45.730952, 126.624970, 212]; %��ʼλ��,�����ر�ȷ
almanac_path = '.\~temp\almanac'; %����洢·��
ephemeris_path = '.\~temp\ephemeris'; %�����洢·��

%% ��ȡ���ջ���ʼʱ��
tf = sscanf(data_file((end-22):(end-8)), '%4d%02d%02d_%02d%02d%02d')'; %�����ļ���ʼ����ʱ��(����ʱ������)
tg = utc2gps(tf, 8); %UTCʱ��ת��ΪGPSʱ��
ta = [tg(2),0,0] + sample2dt(sampleOffset, sampleFreq); %���ջ���ʼʱ��,[s,ms,us]
ta = timeCarry(round(ta,2)); %��λ,΢�뱣��2λС��

%% �������ջ�����(*)
nCoV = GL1CA_S(4e6, [tg(1),ta], msToProcess, p0); %��������
nCoV.get_almanac(almanac_path); %��ȡ����
% nCoV.set_svList(24); %���ø��������б�
nCoV.set_svList([10,15,20,24]);
% nCoV.set_svList([]);

%% (Ԥ������)
% ���Ǳ�Ҫ�Ĳ���,ֻ�ǿ�����ǰ���ж�λ
ephemeris_file = [ephemeris_path,'\',data_file((end-22):(end-8)),'.mat']; %Ԥ��������ļ�
if ~exist(ephemeris_file, 'file') %��������ھʹ���һ��
    ephemeris = []; %������Ϊephemeris,�Ǹ��ṹ��
    save(ephemeris_file, 'ephemeris')
end
nCoV.set_ephemeris(ephemeris_file);

%% ���ļ�,����������
fileID = fopen(data_file, 'r');
fseek(fileID, round(sampleOffset*4), 'bof'); %��ȡ�����ܳ����ļ�ָ���Ʋ���ȥ
if int64(ftell(fileID))~=int64(sampleOffset*4) %����ļ�ָ���Ƿ��ƹ�ȥ��
    error('Sample offset error!');
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

%% (��������)
nCoV.save_ephemeris(ephemeris_file);

%% �������
clearvars -except nCoV tf p0 data_file

%% ��ӡͨ����־
nCoV.print_log;

%% ��ʾ���ٽ��
% nCoV.show_trackResult;
nCoV.plot_constellation;

%% (����)
% GPS.visibility(almanac_path, tf, 8, p0, 1); %��ʾ��ǰ�ɼ�����

%% ������
