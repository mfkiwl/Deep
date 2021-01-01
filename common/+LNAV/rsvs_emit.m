function [rsvs, corr] = rsvs_emit(ephe, te0, rp, vp, iono, lla)
% �����������źŷ���ʱ�̵�λ���ٶ�,����α��α����У����
% ephe:21��������(5+16)
% te0:�ź����巢��ʱ��,[s,ms,us]
% rp:���ջ�ecefλ��(����),���ڼ���SagnacУ��
% vp:���ջ�ecef�ٶ�,���ڼ���SagnacƵ�ʲ�
% iono:�����У������,NaN��ʾ��Ч
% lla:���ջ�γ����,��rp��Ӧ,deg
% rsvs:����ecefλ���ٶ�,[x,y,z,vx,vy,vz]
% corr:α��α����У����,�ṹ��

% ���������������
if length(ephe)~=21
    error('Ephemeris error!')
end

% ��ȡ��������
toc = ephe(1);
af0 = ephe(2);
af1 = ephe(3);
af2 = ephe(4);
TGD = ephe(5);
a = ephe(7)^2; %�볤��
ephe0 = ephe(6:end); %16��������,���ڼ�������λ���ٶ�

% ���������Ӳ�
dt = te0(1) - toc + te0(2)/1e3 + te0(3)/1e6; %s
dt = mod(dt+302400,604800)-302400; %�����ڡ�302400
dtsv = af0 + af1*dt + af2*dt^2; %�����Ӳ�,s
dfsv = af1 + 2*af2*dt; %������Ƶ��,s/s

% �ź�ʵ�ʷ���ʱ��(�ӿ������¼�)
te = te0(3)/1e6 - dtsv + te0(2)/1e3 + te0(1); %s

% ��������λ���ٶ�
[rsvs, dtrel] = LNAV.rsvs_ephe(ephe0, te);

% ����SagancЧӦУ����
w_c2 = 8.113572326725195e-22; %w/c^2, w=7.2921151467e-5, c=299792458
rs = rsvs(1:3);
dtsagnac = (rs(1)*rp(2)-rs(2)*rp(1)) * w_c2;
vs = rsvs(4:6);
dfsagnac = (vs(1)*rp(2)-vs(2)*rp(1)+rs(1)*vp(2)-rs(2)*vp(1)) * w_c2;

% ���������ЧӦ�����������Ƶ��
% ���6ps/s,��������Ƶ��һ������
% <Springer Handbook of Global Navigation Satellite Systems>564ҳ(19.16)
% 2*miu/c^2=0.00887005737336
dfrel = 0.00887005737336 * (1/a - 1/norm(rs));

% ���������ӳ�
if ~isnan(iono(1)) %������Ч
    [azi, ele] = aziele_xyz(rs, lla);
    dtiono = Klobuchar1(iono, azi, ele, lla(1), lla(2), te);
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
corr.dfsagnac = dfsagnac; %SagancЧӦƵ�ʲ�,s/s

end