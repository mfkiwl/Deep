function [rs, dtrel] = rs_ephe(ephe, t)
% ʹ��������������ecefλ��(�������)
% ephe:16��������,ÿ��Ϊ1������
% [toe,sqa,e,dn,M0,omega,Omega0,Omega_dot,i0,i_dot,Cus,Cuc,Crs,Crc,Cis,Cic]
% t:��������
% rs:����ecefλ��,ÿ��Ϊ1������
% dtrel:������Ӳ�,s,������

% ���������������
[svN, paraN] = size(ephe);
if paraN~=16
    error('Ephemeris error!')
end

% GPS�ĵ������ĵ������(GPS�ͱ����������λ�ò�ͦ��,���ʮ����)
miu = 3.986005e14;
w = 7.2921151467e-5;
F = -4.442807633e-10;

% �۲���Ԫ��ο���Ԫ��ʱ���
toe = ephe(1,1);
dt = mod(t-toe+302400,604800)-302400; %�����ڡ�302400

% ������������ecefλ��
rs = zeros(svN,3);
dtrel = zeros(svN,1);
for k=1:svN
    sqa = ephe(k,2);
    a = sqa^2;
    n = sqrt(miu/a^3) + ephe(k,4);
    M = mod(ephe(k,5)+n*dt, 2*pi); %0-2*pi,ƽ�����
    e = ephe(k,3);
    E = kepler(M, e); %0-2*pi,ƫ�����
    sin_E = sin(E);
    cos_E = cos(E);
    sin_v = sqrt(1-e^2)*sin_E; % / (1-e*cos_E);
    cos_v = (cos_E-e); % / (1-e*cos_E);
    v = atan2(sin_v, cos_v); %������
    phi = v + ephe(k,6);
    sin_2phi = sin(2*phi);
    cos_2phi = cos(2*phi);
    du = ephe(k,11)*sin_2phi + ephe(k,12)*cos_2phi;
    dr = ephe(k,13)*sin_2phi + ephe(k,14)*cos_2phi;
    di = ephe(k,15)*sin_2phi + ephe(k,16)*cos_2phi;
    u = phi + du;
    r = a*(1-e*cos(E)) + dr;
    xp = r*cos(u);
    yp = r*sin(u);
    i = ephe(k,9) + ephe(k,10)*dt + di;
    Omega = ephe(k,7) + (ephe(k,8)-w)*dt - w*toe;
    rs(k,1) = xp*cos(Omega) - yp*cos(i)*sin(Omega);
    rs(k,2) = xp*sin(Omega) + yp*cos(i)*cos(Omega);
    rs(k,3) = yp*sin(i);
    dtrel(k) = F*e*sqa*sin_E;
end

end