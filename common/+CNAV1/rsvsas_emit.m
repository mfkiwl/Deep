function [rsvsas, corr] = rsvsas_emit(ephe, te0, rp, iono, lla)
% �����������źŷ���ʱ�̵�λ���ٶȼ��ٶ�,����α��α����У����
% ephe:26��������(19+7)
% te0:�ź����巢��ʱ��,[s,ms,us]
% rp:���ջ�ecefλ��(����),���ڼ���SagnacУ��
% iono:�����У������,NaN��ʾ��Ч
% lla:���ջ�γ����,��rp��Ӧ,deg
% rsvsas:����ecefλ���ٶȼ��ٶ�,[x,y,z,vx,vy,vz,ax,ay,az]
% corr:α��α����У����,�ṹ��

% ���������������
if length(ephe)~=26
    error('Ephemeris error!')
end

% �������
w = 7.292115e-5;
c = 299792458;

% ��ȡ��������
toc = ephe(20);
af0 = ephe(21);
af1 = ephe(22);
af2 = ephe(23);
TGD = ephe(26);
ephe0 = ephe(1:19); %19��������,���ڼ�������λ���ٶ�

% ����볤��
SatType = ephe(2);
dA = ephe(3);
if SatType==1 || SatType==2
    Aref = 42162200; %IGSO/GEO
elseif SatType==3
    Aref = 27906100; %MEO
end
a = Aref + dA; %�ο�ʱ�̵ĳ�����

% ���������Ӳ�
dt = te0(1) - toc + te0(2)/1e3 + te0(3)/1e6; %s
dt = mod(dt+302400,604800)-302400; %�����ڡ�302400
dtsv = af0 + af1*dt + af2*dt^2; %�����Ӳ�,s
dfsv = af1 + 2*af2*dt; %������Ƶ��,s/s

% �ź�ʵ�ʷ���ʱ��(�ӿ������¼�)
te = te0(3)/1e6 - dtsv + te0(2)/1e3 + te0(1); %s

% ��������λ���ٶ�
[rsvsas, dtrel] = CNAV1.rsvsas_ephe(ephe0, te);

% ����SagancЧӦУ����
rs = rsvsas(1:3);
dtsagnac = (rs(1)*rp(2)-rs(2)*rp(1))*w/c^2;

% ���������ЧӦ�����������Ƶ��
dfrel = 0.00887005737336 * (1/a - 1/norm(rs));

% ���������ӳ�
if ~isnan(iono(1)) %������Ч
    dtiono = 0;
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