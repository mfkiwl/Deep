function result = aziele_almanac(almanac, t, p)
% ������������ǵķ�λ�Ǹ߶Ƚ�,���Դ���һ������,Ҳ������һ��
% almanac:8����,[toe,sqa,e,M0,omega,Omega0,Omega_dot,i]
% t:��������
% p:[lat,lon,h],deg,���ջ�λ��
% result:[azi,ele],deg

if size(almanac,2)~=8
    error('Almanac error!')
end

% �������(���㷽λ�Ǹ߶Ƚǲ���̫��ȷ,��ɶ����)
%----GPS�ĵ��и�����
% miu = 3.986005e14;
% w = 7.2921151467e-5;
%----WGS84�ĵ��ͱ����ĵ�������
miu = 3.986004418e14;
w = 7.292115e-5;

% ���ջ�λ��
Cen = dcmecef2ned(p(1), p(2));
rp = lla2ecef(p)'; %���ջ�ecef����

% �۲���Ԫ��ο���Ԫ��ʱ���
toe = almanac(1,1);
dt = mod(t-toe+302400,604800)-302400; %�����ڡ�302400

% ����
N = size(almanac,1); %���Ǹ���
result = zeros(N,2);
for k=1:N
    %----������������
    a = almanac(k,2)^2;
    n = sqrt(miu/a^3);
    M = mod(almanac(k,4)+n*dt, 2*pi); %0-2*pi,ƽ�����
    e = almanac(k,3);
    E = kepler(M, e); %0-2*pi,ƫ�����
    sin_v = sqrt(1-e^2)*sin(E) / (1-e*cos(E));
    cos_v = (cos(E)-e) / (1-e*cos(E));
    v = atan2(sin_v, cos_v); %������
    phi = v+almanac(k,5);
    r = a*(1-e*cos(E));
    xp = r*cos(phi);
    yp = r*sin(phi);
    i = almanac(k,8);
    Omega = almanac(k,6) + (almanac(k,7)-w)*dt - w*toe;
    rs = [xp*cos(Omega) - yp*cos(i)*sin(Omega);
          xp*sin(Omega) + yp*cos(i)*cos(Omega);
          yp*sin(i)]; %����ecef����
    %----�������λ��
    rps = rs-rp; %���ջ�ָ�����ǵ�λ��ʸ��,ecef
    rpsu = rps/norm(rps); %��λʸ��
    rpsu_n = Cen*rpsu; %ת������ϵ��
    %----���㷽λ�Ǹ߶Ƚ�
    result(k,1) = atan2d(rpsu_n(2),rpsu_n(1)); %��λ��,deg
    result(k,2) = asind(-rpsu_n(3)); %�߶Ƚ�,deg
end

end