function [rsvsas, corr] = rsvsas_emit(ephe, te0, rp, iono, lla)
% �����������źŷ���ʱ�̵�λ���ٶȼ��ٶ�,����α��α����У����
% ephe:����,21����(5+16)
% te0:�ź����巢��ʱ��,[s,ms,us]
% rp:���ջ�ecefλ��(����),���ڼ���SagnacУ��
% iono:�����У������,NaN��ʾ��Ч
% lla:���ջ�γ����,��rp��Ӧ,deg
% rsvsas:����ecefλ���ٶȼ��ٶ�,[x,y,z,vx,vy,vz,ax,ay,az]
% corr:α��α����У����,�ṹ��

if length(ephe)~=21
    error('Ephemeris error!')
end

% �������
w = 7.2921151467e-5;
c = 299792458;

% ��ȡ��������
toc = ephe(1);
af0 = ephe(2);
af1 = ephe(3);
af2 = ephe(4);
TGD = ephe(5);

% ���������Ӳ�
dt = te0(1) - toc + te0(2)/1e3 + te0(3)/1e6; %s
dt = mod(dt+302400,604800)-302400; %�����ڡ�302400
dtsv = af0 + af1*dt + af2*dt^2; %�����Ӳ�,s
dfsv = af1 + 2*af2*dt; %������Ƶ��,s/s

% �ź�ʵ�ʷ���ʱ��(�ӿ������¼�)
te = te0(3)/1e6 - dtsv + te0(2)/1e3 + te0(1); %s

% ��������λ���ٶȼ��ٶ�
[rsvsas, dtrel] = LNAV.rsvsas_ephe(ephe(6:end), te);

% ����SagancЧӦУ����
rs = rsvsas(1:3);
dtsagnac = (rs(1)*rp(2)-rs(2)*rp(1))*w/c^2;

% ���������ЧӦ�����������Ƶ��
% ���6ps/s,��������Ƶ��һ������
% <Springer Handbook of Global Navigation Satellite Systems>564ҳ(19.16)
dfrel = 0.00887005737336 * (1/ephe(7)^2 - 1/norm(rs)); %2*miu/c^2=0.00887005737336

% ���������ӳ�
if ~isnan(iono(1)) %������Ч
    % �������Ƿ�λ�Ǹ߶Ƚ�
    Cen = dcmecef2ned(lla(1), lla(2));
    rps = rs-rp; %���ջ�ָ�����ǵ�λ��ʸ��,ecef
    rpsu = rps/norm(rps); %��λʸ��
    rpsu_n = Cen*rpsu'; %ת������ϵ��
    azi = atan2d(rpsu_n(2),rpsu_n(1)); %��λ��,deg
    ele = asind(-rpsu_n(3)); %�߶Ƚ�,deg
    % ʹ��Klobucharģ�ͼ��������ӳ�
    dtiono = Klobuchar(iono, azi, ele, lla(1), lla(2), te);
else
    dtiono = 0;
end

% ���У����
corr.dtsv = dtsv; %�����Ӳ�,s
corr.dtrel = dtrel; %������Ӳ�,s
corr.dtsagnac = dtsagnac; %SagancЧӦ�ӳ�,s
corr.TGD = TGD; %Ⱥ�ӳ�,s
corr.dtiono = dtiono; %������ӳ�,s
corr.dfsv = dfsv; %������Ƶ��,s/s
corr.dfrel = dfrel; %�������Ƶ��,s/s

end