function result = aziele_ephemeris(ephemeris, t, p)
% �������������ǵķ�λ�Ǹ߶Ƚ�,������һ������,Ҳ������һ������
% ephemeris:16����,[toe,sqa,e,dn,M0,omega,Omega0,Omega_dot,i0,i_dot,Cus,Cuc,Crs,Crc,Cis,Cic]
% t:��������
% p:[lat,lon,h],deg,���ջ�λ��
% result:[azi,ele],deg

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
toe = ephemeris(1,1);
dt = t - toe;
if dt>302400
    dt = dt-604800;
elseif dt<-302400
    dt = dt+604800;
end

% ����
N = size(ephemeris,1); %���Ǹ���
result = zeros(N,2);
for k=1:N
    %----������������
    a = ephemeris(k,2)^2;
    n = sqrt(miu/a^3) + ephemeris(k,4);
    M = mod(ephemeris(k,5)+n*dt, 2*pi); %0-2*pi,ƽ�����
    e = ephemeris(k,3);
    E = kepler(M, e); %0-2*pi,ƫ�����
    sin_v = sqrt(1-e^2)*sin(E) / (1-e*cos(E));
    cos_v = (cos(E)-e) / (1-e*cos(E));
    v = atan2(sin_v, cos_v); %������
    phi = v+ephemeris(k,6);
    sin_2phi = sin(2*phi);
    cos_2phi = cos(2*phi);
    du = ephemeris(k,11)*sin_2phi + ephemeris(k,12)*cos_2phi;
    dr = ephemeris(k,13)*sin_2phi + ephemeris(k,14)*cos_2phi;
    di = ephemeris(k,15)*sin_2phi + ephemeris(k,16)*cos_2phi;
    u = phi + du;
    r = a*(1-e*cos(E)) + dr;
    xp = r*cos(u);
    yp = r*sin(u);
    i = ephemeris(k,9) + ephemeris(k,10)*dt + di;
    if i>0.3 %MEO/IGSO
        Omega = ephemeris(k,7) + (ephemeris(k,8)-w)*dt - w*toe;
        rs = [xp*cos(Omega)-yp*cos(i)*sin(Omega);
              xp*sin(Omega)+yp*cos(i)*cos(Omega);
              yp*sin(i)]; %����ecef����
    else %GEO
        Omega = ephemeris(k,7) + ephemeris(k,8)*dt - w*toe;
        rs = [xp*cos(Omega)-yp*cos(i)*sin(Omega);
              xp*sin(Omega)+yp*cos(i)*cos(Omega);
              yp*sin(i)]; %�������Զ�������ϵ�е�����
        psi = -5/180*pi;
        Rx = [1,0,0; 0,cos(psi),sin(psi); 0,-sin(psi),cos(psi)];
        psi = w*dt;
        Rz = [cos(psi),sin(psi),0; -sin(psi),cos(psi),0; 0,0,1];
        rs = Rz*Rx*rs; %����ecef����
    end
    %----�������λ��
    rps = rs-rp; %���ջ�ָ�����ǵ�λ��ʸ��,ecef
    rpsu = rps/norm(rps); %��λʸ��
    rpsu_n = Cen*rpsu; %ת������ϵ��
    %----���㷽λ�Ǹ߶Ƚ�
    result(k,1) = atan2d(rpsu_n(2),rpsu_n(1)); %��λ��,deg
    result(k,2) = asind(-rpsu_n(3)); %�߶Ƚ�,deg
end

end