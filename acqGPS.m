valid_prefix = 'B210-SIM-'; %�ļ�����Чǰ׺
[file, path] = uigetfile('*.dat', 'ѡ��GNSS�����ļ�'); %�ļ�ѡ��Ի���
if ~ischar(file) || ~contains(valid_prefix, strtok(file,'_'))
    error('File error!')
end
filename = [path, file]; %�����ļ�����·��,path����\

fs = 4e6;
acqConf.time = 2;
acqConf.freqMax = 5e3;
acqConf.threshold = 1.4;
acqResult = GPS.L1CA.acquisition(filename, fs, 0*fs, acqConf);