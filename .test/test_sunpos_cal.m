% ����̫��λ�ü���
% ʹ��������������̫��λ��
% ���ָ���ص�ָ�����ڵ�̫���߶ȽǱ仯����
% planetEphemeris���International Celestial Reference Frame (ICRF)�µ�λ��
% ICRF��J2000�ǳ��ӽ�,https://blog.csdn.net/stk10/article/details/103263324/

%% λ�ú�����
date0 = [2021,5,31]; %������
dnum0 = datenum(date0(1),date0(2),date0(3)) - 1/3; %��ʼʱ�̵�ʱ��
p0 = [38.0463, 114.4358, 100];
% p0 = [45.7364, 126.70775, 165];
rp = lla2ecef(p0);
Cen = dcmecef2ned(p0(1), p0(2));

%% ���
ele = zeros(288,1); %̫���߶Ƚ�,deg
azi = zeros(288,1); %̫����λ��,deg

%% ����
for k=1:288 %ÿ��5����һ��
    dnum = dnum0+k/288;
    utc = datevec(dnum); %ת����UTCʱ��ʸ��
    rs = planetEphemeris(juliandate(utc),'Earth','Sun')*1000; %̫����ICRF�е�λ��
    Cie = dcmeci2ecef('IAU-2000/2006',utc);
    rs = rs*Cie'; %̫����ECEFϵ�µ�λ��
    rps = rs - rp; %���ڵ�ָ��̫����λ��ʸ��
    rpsu = rps / norm(rps);
    rpsu_n = rpsu*Cen';
    ele(k) = -asind(rpsu_n(3));
    azi(k) = atan2d(rpsu_n(2),rpsu_n(1));
end

%% ��ͼ
t = dnum0 + 1/3 + (1:288)'/288;
figure
subplot(2,1,1)
plot(t,ele)
datetick('x',15)
grid on
subplot(2,1,2)
plot(t,attContinuous(azi))
datetick('x',15)
grid on

t = (1:288)'/12;
figure
subplot(2,1,1)
plot(t,ele)
set(gca, 'XLim',[0,24])
grid on
subplot(2,1,2)
plot(t,attContinuous(azi))
set(gca, 'XLim',[0,24])
grid on