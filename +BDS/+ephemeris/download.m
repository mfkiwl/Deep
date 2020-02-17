function download(filepath, date)
% ����BDS�㲥����
% filepath:�ļ��洢·��,��β����\
% date:����,'yyyy-mm-dd',�ַ���

% BDS broadcast ephemeris
% http://www.csno-tarc.cn/support/downloads

% �����ļ���
day_of_year = date2day(date(1:10)); %��ǰ������һ��ĵڼ���
year = date(1:4); %����ַ���
day = sprintf('%03d', day_of_year); %�����ַ���,��λ,ǰ�油��
ftppath = ['/brdc/',year,'/']; %ftp·��
filename = ['tarc',day,'0.',year(3:4),'b'];

% ����
ftpobj = ftp('59.252.100.32', 'tarc', 'gnsscenter'); %����ftp������
cd(ftpobj, ftppath); %�����ļ���
mget(ftpobj, filename, filepath); %�����ļ�,ָ���洢�ļ���
close(ftpobj); %�ر�����

% ����Ƿ����سɹ�
filename = [filepath,'\',filename]; %����·�����ļ���
if exist(filename,'file')==2 %����Ƿ����سɹ�
    disp('Download succeeded!')
else
    disp('Download failed!')
end

end