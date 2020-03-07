function plot_gnss_file
% �۲�GNSS�ļ��е�����

valid_prefix = 'B210-'; %�ļ�����Чǰ׺

% ѡ���ļ�
[file, path] = uigetfile('*.dat', 'ѡ��GNSS�����ļ�'); %�ļ�ѡ��Ի���
if file==0 %ȡ��ѡ��,file����0,path����0
    disp('Invalid file!')
    return
end
if ~contains(valid_prefix, strtok(file,'_')) %����ļ���ǰ׺�Ƿ���Ч
    error('File error!')
end
data_file = [path, file]; %�����ļ�����·��,path����\

% ȡǰһ�ε�����
fs = 4e6;
n = fs * 0.1; %���ݵ���
fileID = fopen(data_file, 'r');
data = fread(fileID, [2,n], 'int16'); %��������
fclose(fileID);

% ��ͼ
t = (1:n)/fs;
figure
plot(t, data(1,:)) %ʵ��
hold on
plot(t, data(2,:)) %�鲿
xlabel('\itt\rm(s)')

end