function filename = download(filepath, date)
% ����BDS�㲥����
% filepath:�ļ��洢·��,��β����\
% date:����,'yyyy-mm-dd',�ַ���

% BDS broadcast ephemeris
% http://www.csno-tarc.cn/support/downloads

% ���Ŀ���ļ����Ƿ����
if ~exist(filepath,'dir')
    error('File path doesn''t exist!')
end

% �����ļ���
day_of_year = date2day(date(1:10)); %��ǰ������һ��ĵڼ���
year = date(1:4); %����ַ���
day = sprintf('%03d', day_of_year); %�����ַ���,��λ,ǰ�油��
ftppath = ['/brdc/',year,'/']; %ftp·��
ftpfile = ['tarc',day,'0.',year(3:4),'b']; %ftp�ļ���
filename = [filepath,'\',ftpfile]; %���������ļ���

% ����ļ��Ѵ���,ֱ�ӷ���
if exist(filename,'file')
    return
end

% ����
% ftpobj = ftp('59.252.100.32', 'tarc', 'gnsscenter'); %����ftp������
ftpobj = ftp('ftp2.csno-tarc.cn', 'pub', 'tarc'); %����ftp������
cd(ftpobj, ftppath); %�����ļ���
mget(ftpobj, ftpfile, filepath); %�����ļ�,ָ���洢�ļ���
close(ftpobj); %�ر�����

end