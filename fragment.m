%% ���ó���Ƭ��

%% ���·��

% addpath(genpath('xxx')) %�������ļ���
addpath('common')
addpath('override')
addpath('receiver')

%% �Ƴ�·��

% rmpath(genpath('xxx')) %�������ļ���
rmpath('common')
rmpath('override')
rmpath('receiver')

%% �������
%  ����GPS���鲢��ȡ
filename = GPS.almanac.download('~temp\almanac', UTC2GPS([2020,2,23,15,0,0],8));
almanac = GPS.almanac.read(filename);
%%
%  ����BDS���鲢��ȡ
filename = BDS.almanac.download('~temp\almanac', '2020-07-16');
almanac = BDS.almanac.read(filename);

%% �������
%  ����GPS��������ȡ
filename = GPS.ephemeris.download('~temp\ephemeris', '2020-02-22');
ephe = RINEX.read_N2(filename);
%%
%  ����BDS��������ȡ
filename = BDS.ephemeris.download('~temp\ephemeris', '2020-02-22');
ephe = RINEX.read_B303(filename);

%% ����ͼ
%  ��ʾGPS����ͼ
c = [2020,2,23,11,50,0];
p = [42.27452, 123.85232, 105];
ax = GPS.constellation('~temp\almanac', c, 8, p);
%%
%  ��ʾBDS����ͼ
c = [2020,2,23,11,50,0];
p = [42.27452, 123.85232, 105];
ax = BDS.constellation('~temp\ephemeris', c, 8, p);
%%
%  ͬʱ��ʾGPS,BDS����ͼ
c = [2020,2,23,11,50,0];
p = [42.27452, 123.85232, 105];
ax = GPS.constellation('~temp\almanac', c, 8, p);
ax = BDS.constellation('~temp\ephemeris', c, 8, p, ax);
%%
%  ��ʾδ��һ��ʱ��GPS���ǹ켣
c = [2020,2,23,11,50,0];
p = [42.27452, 123.85232, 105];
GPS.visibility('~temp\almanac', c, 8, p, 1);

%% kml���
%  γ�Ⱦ���д��kml�ļ�
kmlwriteline('~temp\traj.kml', nCoV.storage.pos(:,1),nCoV.storage.pos(:,2), 'Color','r', 'Width',2);

%% �����
%  ����һ���еĵ����У��ֵ
date = '2019-08-26';
p = [45.730952, 126.624970, 212];
GPS.iono_24h('~temp\ephemeris', date, p, 8, 10);

%% ����
%  GPS L1 C/A�źŲ���
filename = 'C:\Users\longt\Desktop\B210_20190823_194010_ch1.dat';
fs = 4e6;
acqConf.time = 2;
acqConf.freqMax = 5e3;
acqConf.threshold = 1.4;
acqResult = GPS.L1CA.acquisition(filename, fs, 0*fs, acqConf);

%%
%  ����B1C�źŲ���
filename = 'C:\Users\longt\Desktop\B210_20190823_194010_ch1.dat';
fs = 4e6;
acqConf.freqMax = 5e3;
acqConf.threshold = 1.4;
acqResult = BDS.B1C.acquisition(filename, fs, 0*fs, acqConf);