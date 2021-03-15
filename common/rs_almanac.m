function rs = rs_almanac(almanac, t)
% ʹ�������������ecefλ��(�������)
% almanac:9��������,ÿ��Ϊ1������
% [week,toe,sqa,e,M0,omega,Omega0,Omega_dot,i]
% t:[week,second]
% rs:����ecefλ��,ÿ��Ϊ1������

% ��������������
[svN, paraN] = size(almanac); %���Ǹ����Ͳ�������
if paraN~=9
    error('Almanac error!')
end

% �������(����̫��ȷ,���ĸ�����)
%----GPS�ĵ��и�����
% miu = 3.986005e14;
% w = 7.2921151467e-5;
%----WGS84�ĵ��ͱ����ĵ�������
miu = 3.986004418e14;
w = 7.292115e-5;

% �۲���Ԫ��ο���Ԫ��ʱ���
toe = almanac(1,2);
dt = rem(t(1)-almanac(1,1),1024)*604800 + (t(2)-toe);

% ������������ecefλ��
rs = zeros(svN,3);
for k=1:svN
    a = almanac(k,3)^2;
    n = sqrt(miu/a^3);
    M = mod(almanac(k,5)+n*dt, 2*pi); %0-2*pi,ƽ�����
    e = almanac(k,4);
    E = kepler(M, e); %0-2*pi,ƫ�����
    sin_v = sqrt(1-e^2)*sin(E) / (1-e*cos(E));
    cos_v = (cos(E)-e) / (1-e*cos(E));
    v = atan2(sin_v, cos_v); %������
    phi = v+almanac(k,6);
    r = a*(1-e*cos(E));
    xp = r*cos(phi);
    yp = r*sin(phi);
    i = almanac(k,9);
    Omega = almanac(k,7) + (almanac(k,8)-w)*dt - w*toe;
    rs(k,1) = xp*cos(Omega) - yp*cos(i)*sin(Omega);
    rs(k,2) = xp*sin(Omega) + yp*cos(i)*cos(Omega);
    rs(k,3) = yp*sin(i);
end

end