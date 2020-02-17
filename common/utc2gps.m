function t = utc2gps(c, zone)
% UTCʱ��ת��ΪGPS�ܺ�GPS��
% c:[year, mon, date, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% t:[week,second],GPS����,��0��ʼһֱ��

% datenum(1980,1,6)  = 723186
% datenum(1999,8,22) = 730354
% datenum(2019,4,7)  = 737522

% ��������ʱ����������
leap = 18; %UTC������,UTCÿ��1s,GPSʱ��ᳬǰ1s

day = datenum(c(1),c(2),c(3)) - 723186; %���GPSʱ�������˶�����
week = floor(day/7);
second = (day-week*7)*86400 + c(4)*3600 + c(5)*60 + floor(c(6)); %86400=24*3600
second = second - zone*3600 + leap;
if second<0
    second = second + 604800; %604800=7*24*3600
    week = week - 1;
elseif second>=604800
    second = second - 604800;
    week = week + 1;
end
t = [week, second];

end