function [rsvs, dtrel] = rsvs_ephe(ephe, t)
% ʹ��������������ecefλ���ٶ�(��������)
% ephe:19��������
% [toe,SatType,dA,A_dot,dn0,dn0_dot,M0,e,omega,Omega0,i0,Omega_dot,i0_dot
%  Cis,Cic,Crs,Crc,Cus,Cuc]
% t:��������
% rsvs:[x,y,z,vx,vy,vz]
% dtrel:������Ӳ�,s
% �μ�<�ռ��źŽӿڿ����ļ� B1C 1.0>

% ���������������
if length(ephe)~=19
    error('Ephemeris error!')
end

% �������
miu = 3.986004418e14;
w = 7.292115e-5;
F = -4.442807309e-10;

% ��ȡ��������
toe = ephe(1);
SatType = ephe(2);
dA = ephe(3);
A_dot = ephe(4);
dn0 = ephe(5);
dn0_dot = ephe(6);
M0 = ephe(7);
e = ephe(8);
omega = ephe(9);
Omega0 = ephe(10);
i0 = ephe(11);
Omega_dot = ephe(12);
i0_dot = ephe(13);
Cis = ephe(14);
Cic = ephe(15);
Crs = ephe(16);
Crc = ephe(17);
Cus = ephe(18);
Cuc = ephe(19);

%% ��������λ��
if SatType==1 || SatType==2
    Aref = 42162200; %IGSO/GEO
elseif SatType==3
    Aref = 27906100; %MEO
end
dt = mod(t-toe+302400,604800)-302400; %�����ڡ�302400
A0 = Aref + dA; %�ο�ʱ�̵ĳ�����
A = A0 + A_dot*dt; %������
n0 = sqrt(miu/A0^3);
dn = dn0 + 0.5*dn0_dot*dt;
n = n0 + dn; %ƽ�����ٶ�
M = mod(M0+n*dt, 2*pi); %0-2*pi,ƽ�����
E = kepler(M, e); %0-2*pi,ƫ�����
sin_E = sin(E);
cos_E = cos(E);
sin_v = sqrt(1-e^2)*sin_E / (1-e*cos_E);
cos_v = (cos_E-e) / (1-e*cos_E);
v = atan2(sin_v, cos_v); %������
phi = v + omega;
sin_2phi = sin(2*phi);
cos_2phi = cos(2*phi);
du = Cus*sin_2phi + Cuc*cos_2phi;
dr = Crs*sin_2phi + Crc*cos_2phi;
di = Cis*sin_2phi + Cic*cos_2phi;
u = phi + du;
sin_u = sin(u);
cos_u = cos(u);
r = A*(1-e*cos_E) + dr;
xp = r*cos_u;
yp = r*sin_u;
i = i0 + i0_dot*dt + di;
sin_i = sin(i);
cos_i = cos(i);
Omega = Omega0 + (Omega_dot-w)*dt - w*toe;
sin_Omega = sin(Omega);
cos_Omega = cos(Omega);
x = xp*cos_Omega - yp*cos_i*sin_Omega;
y = xp*sin_Omega + yp*cos_i*cos_Omega;
z = yp*sin_i;

%% ���������ٶ�
d_E = (n0+dn0+dn0_dot*dt)/(1-e*cos_E); %�б仯
d_phi = sqrt(1-e^2)*d_E/(1-e*cos_E);
d_r = A_dot*(1-e*cos_E) + A*e*sin_E*d_E + 2*(Crs*cos_2phi-Crc*sin_2phi)*d_phi;
d_u = d_phi + 2*(Cus*cos_2phi-Cuc*sin_2phi)*d_phi;
d_Omega = Omega_dot-w;
d_i = i0_dot + 2*(Cis*cos_2phi-Cic*sin_2phi)*d_phi;
d_xp = d_r*cos_u - r*sin_u*d_u;
d_yp = d_r*sin_u + r*cos_u*d_u;
vx = d_xp*cos_Omega - d_yp*cos_i*sin_Omega + yp*sin_i*sin_Omega*d_i - y*d_Omega;
vy = d_xp*sin_Omega + d_yp*cos_i*cos_Omega - yp*sin_i*cos_Omega*d_i + x*d_Omega;
vz = d_yp*sin_i + yp*cos_i*d_i;

%% ���
rsvs = [x,y,z,vx,vy,vz];
dtrel = F*e*sqrt(A)*sin_E;

end