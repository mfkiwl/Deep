function dtiono = Klobuchar2(iono, azi, ele, lat, lon, t)
% ����Klobucharģ�ͼ��������ӳ�
% �ο�BDS�ӿ��ĵ�,<ESA_GNSS-Book_TM-23_Vol_I>P117
% azi,ele:���Ƿ�λ�Ǹ߶Ƚ�,deg
% lat,lon:���ջ�γ�Ⱦ���,deg
% t:��������
% dtiono:������ӳ�,s
% ���������Ƶ���źŵĵ�����ӳ�,����(f1^2/f2^2),������ӳ���Ƶ�ʵ�ƽ���ɷ���

alpha = iono(1:4);
beta = iono(5:8);

R = 6378/(6378+350);

% ����λ�Ǹ߶Ƚ�,γ�Ⱦ��ȵ�λ�Ӷ�תΪ����
A = azi/180*pi;
E = ele/180*pi;
lat_u = lat/180*pi;
lon_u = lon/180*pi;

% �������㴩�̵�λ��
% ���ջ�λ�������㴩�̵�ĵ����Ž�,rad
psi = pi/2 - E - asin(R*cos(E));
% ����㴩�̵�ĵ���γ��,rad
lat_i = asin(sin(lat_u)*cos(psi)+cos(lat_u)*sin(psi)*cos(A));
% ����㴩�̵�ĵ�����,rad
lon_i = lon_u + psi*sin(A)/cos(lat_i);
% ����㴩�̵�ĵش�γ��rad
lat_m = asin(sin(lat_i)*sind(78.3)+cos(lat_i)*cosd(78.3)*cos(lon_i-291/180*pi));
lat_m = lat_m/pi; %����

% �����ֵ(��ֵ)
AMP = alpha * [1;lat_m;lat_m^2;lat_m^3];
if AMP<0
    AMP = 0;
end

% ��������
PER = beta * [1;lat_m;lat_m^2;lat_m^3];
if PER<72000
    PER = 72000; %��С20Сʱ
end

% ����ʱ��
t = 43200*lon_i/pi + t; %�������㴩�̵�ı���ʱ��,43200=12*3600
t = mod(t,86400); %ȡģ,��һ��֮��,86400=24*3600
x = 2*(t-50400)/PER; %rad,50400=14*3600,����2��Ϊ������ӳٷ�ֵ
% ��Ϊͻ��߽�Ϊpi/2,PER��СΪ20Сʱ,����ͻ���������Ϊ5Сʱ

% ���������ӳ�
F = 1/sqrt(1-(R*cos(E))^2);
if abs(x)<0.5
    dtiono = F*(5e-9 + AMP*cospi(x));
else
    dtiono = F*5e-9;
end

end