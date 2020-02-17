function download(filepath, date)
% ����GPS�㲥����
% filepath:�ļ��洢·��,��β����\
% date:����,'yyyy-mm-dd',�ַ���
% ʹ��ǰ�轫winRAR��װ·������ϵͳ��������

% GPS broadcast ephemeris
% https://cddis.nasa.gov/Data_and_Derived_Products/GNSS/broadcast_ephemeris_data.html

% �����ļ���
day_of_year = date2day(date(1:10)); %��ǰ������һ��ĵڼ���
year = date(1:4); %����ַ���
day = sprintf('%03d', day_of_year); %�����ַ���,��λ,ǰ�油��
ftppath = ['/gnss/data/daily/',year,'/brdc/']; %ftp·��
filename = ['brdc',day,'0.',year(3:4),'n.Z'];

% ����
ftpobj = ftp('cddis.nasa.gov'); %����ftp������
cd(ftpobj, ftppath); %�����ļ���
mget(ftpobj, filename, filepath); %�����ļ�,ָ���洢�ļ���
close(ftpobj); %�ر�����

% ����Ƿ����سɹ�,��ѹ
filename = [filepath,'\',filename]; %����·�����ļ���
if exist(filename,'file')==2 %����Ƿ����سɹ�
    disp('Download succeeded!')
    system(['winrar x -o+ "',filename,'" "',filepath,'"']); %-o+ѡ��,�����ļ�
    delete(filename) %ɾ��ѹ���ļ�
else
    disp('Download failed!')
end

end