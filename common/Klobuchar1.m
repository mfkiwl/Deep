function dtiono = Klobuchar1(iono, azi, ele, lat, lon, t)
% ����Klobucharģ�ͼ��������ӳ�
% �ο�GPS�ӿ��ĵ�
% azi,ele:���Ƿ�λ�Ǹ߶Ƚ�,deg
% lat,lon:���ջ�γ�Ⱦ���,deg
% t:��������
% dtiono:������ӳ�,s
% ���������Ƶ���źŵĵ�����ӳ�,����(f1^2/f2^2),������ӳ���Ƶ�ʵ�ƽ���ɷ���

alpha = iono(1:4);
beta = iono(5:8);

% ����λ�Ǹ߶Ƚ�,γ�Ⱦ��ȵ�λ�Ӷ�תΪ����
A = azi/180;
E = ele/180;
lat_u = lat/180;
lon_u = lon/180;

% �������㴩�̵�λ��
psi = 0.0137/(E+0.11) - 0.022; %���ջ�λ�������㴩�̵�ĵ����Ž�,����
lat_i = lat_u + psi*cospi(A); %����㴩�̵�ĵ���γ��,����
if lat_i>0.416
    lat_i = 0.416;
elseif lat_i<-0.416
    lat_i = -0.416;
end
lon_i = lon_u + psi*sinpi(A)/cospi(lat_i); %����㴩�̵�ĵ�����,����
lat_m = lat_i + 0.064*cospi(lon_i-1.617); %����㴩�̵�ĵش�γ��,����

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
t = 43200*lon_i + t; %�������㴩�̵�ı���ʱ��,43200=12*3600
t = mod(t,86400); %ȡģ,��һ��֮��,86400=24*3600
x = 2*(t-50400)/PER; %rad,50400=14*3600,����2��Ϊ������ӳٷ�ֵ
% ��Ϊͻ��߽�Ϊpi/2,PER��СΪ20Сʱ,����ͻ���������Ϊ5Сʱ

% ���������ӳ�
F = 1 + 16*(0.53-E)^3;
if abs(x)<0.5
    dtiono = F*(5e-9 + AMP*cospi(x));
else
    dtiono = F*5e-9;
end

end