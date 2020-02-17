function result = aziele_almanac(almanac, t, p)
% ������������ǵķ�λ�Ǹ߶Ƚ�,���Դ���һ������,Ҳ������һ��
% almanac:[week, toe, af0, af1, sqa, e, M0, omega, Omega0, Omega_dot, i],11����
% t:[week,second]
% p:[lat,lon,h],deg,���ջ�λ��
% result:[azi,ele],deg

miu = 3.986005e14;
w = 7.2921151467e-5;

Cen = dcmecef2ned(p(1), p(2));
rp = lla2ecef(p)'; %���ջ�ecef����

toe = almanac(1,2);
week = mod(t(1),1024); %����ȡģ
tk = (week-almanac(1,1))*604800 + (t(2)-toe);

N = size(almanac,1); %���Ǹ���
result = zeros(N,2);

for k=1:N
    %----������������
    a = almanac(k,5)^2;
    n = sqrt(miu/a^3);
    M = mod(almanac(k,7)+n*tk, 2*pi); %0-2*pi,ƽ�����
    e = almanac(k,6);
    E = kepler(M, e); %0-2*pi,ƫ�����
    sin_v = sqrt(1-e^2)*sin(E) / (1-e*cos(E));
    cos_v = (cos(E)-e) / (1-e*cos(E));
    v = atan2(sin_v, cos_v); %������
    phi = v+almanac(k,8);
    i = almanac(k,11);
    Omega = almanac(k,9) + (almanac(k,10)-w)*tk - w*toe;
    r = a*(1-e*cos(E));
    x = r*cos(phi);
    y = r*sin(phi);
    rs = [x*cos(Omega)-y*cos(i)*sin(Omega);
          x*sin(Omega)+y*cos(i)*cos(Omega);
          y*sin(i)]; %����ecef����
    %----�������λ��
    rps = rs-rp; %���ջ�ָ�����ǵ�λ��ʸ��,ecef
    rpsu = rps/norm(rps); %��λʸ��
    rpsu_n = Cen*rpsu; %ת������ϵ��
    %----���㷽λ�Ǹ߶Ƚ�
    result(k,1) = atan2d(rpsu_n(2),rpsu_n(1)); %��λ��,deg
    result(k,2) = asind(-rpsu_n(3)); %�߶Ƚ�,deg
end

end