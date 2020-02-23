function t = UTC2BDT(c, zone)
% UTCʱ��ת��ΪBDT�ܺ�BDT��
% c:[year, mon, day, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% t:[week,second]

% datenum(2006,1,1) = 732678

% ��������ʱ����������
leap = 4; %UTC������,UTCÿ��1s,BDT�ᳬǰ1s

day = datenum(c(1),c(2),c(3)) - 732678; %���BDTʱ�������˶�����
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