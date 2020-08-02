function filename = download(filepath, t)
% ����GPS����
% filepath:�ļ��洢·��,��β����\
% t:[week,second],GPS����(����ʼ�ܿ�ʼ��),GPS��������
% http://celestrak.com

% ���Ŀ���ļ����Ƿ����
if ~exist(filepath,'dir')
    error('File path doesn''t exist!')
end

% ���������������
day = 723186 + t(1)*7; %serial date number, datenum(1980,1,6)=723186
DateString = datestr(day); %'dd-mmm-yyyy'
year = DateString(8:11); %����ַ���

% ���������ļ���,����ȡ1024��ģ
week = mod(t(1),1024);
second = t(2);
if second<61440
    w = sprintf('%04d',week);
    s = '061440';
elseif second<147456
    w = sprintf('%04d',week);
    s = '147456';
elseif second<233472
    w = sprintf('%04d',week);
    s = '233472';
elseif second<319488
    w = sprintf('%04d',week);
    s = '319488';
elseif second<405504
    w = sprintf('%04d',week);
    s = '405504';
elseif second<589824
    w = sprintf('%04d',week);
    s = '589824';
else
    w = sprintf('%04d',mod(week+1,1024));
    s = '061440';
end
filename = [filepath,'\',w,'_',s,'.txt'];

% ����ļ�������,��������
if ~exist(filename,'file')
    url = ['http://celestrak.com/GPS/almanac/Yuma/',year,'/almanac.yuma.week',w,'.',s,'.txt'];
    websave(filename, url);
end

end