function filename = download(filepath, date)
% ����GPS�㲥����
% filepath:�ļ��洢·��,��β����\
% date:����,'yyyy-mm-dd',�ַ���
% ʹ��ǰ�轫winRAR��װ·������ϵͳ��������

% GPS broadcast ephemeris
% https://cddis.nasa.gov/Data_and_Derived_Products/GNSS/broadcast_ephemeris_data.html

%%
% % ���Ŀ���ļ����Ƿ����
% if ~exist(filepath,'dir')
%     error('File path doesn''t exist!')
% end
% 
% % �����ļ���
% day_of_year = date2day(date(1:10)); %��ǰ������һ��ĵڼ���
% year = date(1:4); %����ַ���
% day = sprintf('%03d', day_of_year); %�����ַ���,��λ,ǰ�油��
% ftppath = ['/gnss/data/daily/',year,'/brdc/']; %ftp·��
% ftpfile = ['brdc',day,'0.',year(3:4),'n.Z']; %ftp�ļ���
% Zfile = [filepath,'\',ftpfile]; %����ѹ���ļ���
% filename = Zfile(1:end-2); %���������ļ���
% 
% % ����ļ��Ѵ���,ֱ�ӷ���
% if exist(filename,'file')
%     return
% end
% 
% % ����
% ftpobj = ftp('cddis.nasa.gov'); %����ftp������
% cd(ftpobj, ftppath); %�����ļ���
% mget(ftpobj, ftpfile, filepath); %�����ļ�,ָ���洢�ļ���
% close(ftpobj); %�ر�����
% 
% % ��ѹ�ļ�
% system(['winrar x -o+ "',Zfile,'" "',filepath,'"']); %-o+ѡ��,�����ļ�
% delete(Zfile) %ɾ��ѹ���ļ�

%%
% ftp://cddis.nasa.gov��2020��10��31�վͲ���������¼��
% ��ftp://gssc.esa.int

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
ftpobj = ftp('gssc.esa.int'); %����ftp������
cd(ftpobj, ftppath); %�����ļ���
filelist = dir(ftpobj); %��ȡ�ļ��б�
filelist = {filelist.name}'; %ֻҪ�ļ���,���Ԫ������������
if any(strcmp(filelist,ftpfile)) %����Ƿ�����ļ�
    mget(ftpobj, ftpfile, filepath); %�����ļ�,ָ���洢�ļ���
    close(ftpobj); %�ر�����
else
    ftpfile = [ftpfile(1:end-1),'gz']; %����gz��β���ļ�
    if any(strcmp(filelist,ftpfile)) %����Ƿ�����ļ�
        mget(ftpobj, ftpfile, filepath); %�����ļ�,ָ���洢�ļ���
        close(ftpobj); %�ر�����
        Zfile = [filepath,'\',ftpfile]; %����ѹ���ļ���
    else
        close(ftpobj); %�ر�����
        error('File doesn''t exist!')
    end
end

% ��ѹ�ļ�
status = system(['winrar x -o+ "',Zfile,'" "',filepath,'"']); %-o+ѡ��,�����ļ�
if status==0 %0��ʾִ�гɹ�
    delete(Zfile) %ɾ��ѹ���ļ�
else
    warning('ϵͳ����������û��WinRAR·��,�����,���ֶ���ѹ�ļ�')
end

end