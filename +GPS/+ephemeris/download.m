function filename = download(filepath, date)
% ����GPS�㲥����
% filepath:�ļ��洢·��,��β����\
% date:����,'yyyy-mm-dd',�ַ���
% ʹ��ǰ�轫winRAR��װ·������ϵͳ��������

% GPS broadcast ephemeris
% https://cddis.nasa.gov/Data_and_Derived_Products/GNSS/broadcast_ephemeris_data.html

% ���Ŀ���ļ����Ƿ����
if ~exist(filepath,'dir')
    error('File path doesn''t exist!')
end

% �����ļ���
day_of_year = date2day(date(1:10)); %��ǰ������һ��ĵڼ���
year = date(1:4); %����ַ���
day = sprintf('%03d', day_of_year); %�����ַ���,��λ,ǰ�油��
ftppath = ['/gnss/data/daily/',year,'/brdc/']; %ftp·��
ftpfile = ['brdc',day,'0.',year(3:4),'n.Z']; %ftp�ļ���
Zfile = [filepath,'\',ftpfile]; %����ѹ���ļ���
filename = Zfile(1:end-2); %���������ļ���

% ����ļ��Ѵ���,ֱ�ӷ���
if exist(filename,'file')
    return
end

% ����
ftpobj = ftp('cddis.nasa.gov'); %����ftp������
cd(ftpobj, ftppath); %�����ļ���
mget(ftpobj, ftpfile, filepath); %�����ļ�,ָ���洢�ļ���
close(ftpobj); %�ر�����

% ��ѹ�ļ�
system(['winrar x -o+ "',Zfile,'" "',filepath,'"']); %-o+ѡ��,�����ļ�
delete(Zfile) %ɾ��ѹ���ļ�

end