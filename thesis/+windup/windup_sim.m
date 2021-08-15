% ����������תʱ��λ����ЧӦ������ز���λ����Ƶ�����
clear
clc

%% ��������
load('~temp\ephemeris\20200727_111614.mat')
ephe = ephemeris.GPS_ephe;
svList = [1,3,6,17,19,22,28]; %�ɼ������б�
svN = length(svList);

%% λ��ʱ����Ϣ
p0 = [45.7364, 126.70775, 165];
rp = lla2ecef(p0);
Cen = dcmecef2ned(p0(1), p0(2));
t0 = 98192;

%% ��������λ��
sv = zeros(svN,3);
for k=1:svN
    PRN = svList(k);
    rsvs = LNAV.rsvs_ephe(ephe(PRN,10:25), t0);
    sv(k,:) = rsvs(1:3);
end

%% ����̫��λ��
utc = [2020,7,27,3,16,14]; %�������t0����
rt = planetEphemeris(juliandate(utc),'Earth','Sun')*1000; %̫��eciλ��
Cie = dcmeci2ecef('IAU-2000/2006',utc);
rt = rt*Cie'; %̫��ecefλ��
% ��һ��̫���߶ȽǷ�λ��,������ĶԲ���
rpt = rt - rp;
rptu = rpt / norm(rpt);
rptu_n = rptu*Cen';
ele = -asind(rptu_n(3)); %̫���߶Ƚ�
azi = atan2d(rptu_n(2),rptu_n(1)); %̫����λ��

%% ����
n = 180; %ÿ2��һ��
er = [0.1, 0.1, 1]; %��ת�᷽��
eru = er / norm(er); %��λʸ��
omega = 100; %��ת���ٶ�,deg/s
wb = eru * omega/180*pi; %��ϵ�µĽ��ٶ�ʸ��,rads
phi = zeros(n,svN); %��
phidot = zeros(n,svN); %Hz
att = zeros(n,3);
for k=1:n
    for m=1:svN
        % ����������̬
        rs = sv(m,:);
        cs = -rs / norm(rs); %����ָ����ĵĵ�λʸ��,z'��
        rst = rt - rs; %����ָ��̫��ʸ��
        bs = cross(cs,rst);
        bs = bs / norm(bs); %y'��
        as = cross(bs,cs); %x'��
        % ���ߵ�λʸ��
        rsp = rp - rs; %����ָ����ջ�
        rspu = rsp / norm(rsp);
        % ���ջ�������̬
        theta_2 = (k-1)/180*pi; %rad
        q = [cos(theta_2), eru*sin(theta_2)];
        Cnb = quat2dcm(q);
        Ceb = Cnb*Cen;
        [r1,r2,r3] = quat2angle(q);
        att(k,:) = [r1,r2,r3]/pi*180;
        % ������λ����ЧӦ
        [phi(k,m), phidot(k,m)] = windup(as, bs, rspu, wb, Ceb);
        % ɾ�������߷���ͼ���µ�
        rpsu = -rspu; %���ջ�ָ������
        rpsu_b = rpsu*Ceb'; %ת����ϵ��
        if(-asind(rpsu_b(3))<5)
            phi(k,m) = NaN;
            phidot(k,m) = NaN;
        end
    end
end
% ����λ������
for k=1:svN
    phi(:,k) = attContinuous(phi(:,k)*360)/360;
end
% ���Ƶ����öԲ���
phidiff = diff(phi,1,1) / (2/omega); %��phidot�Ƚ�
phidot = round(phidot,8);

%% ��ͼ
dt = 2/omega;
t = (0:n-1)*dt;

figure
plot(t,phi)
grid on

figure
plot(t,phidot, 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[0,n*dt])
xlabel('ʱ��/(s)')
ylabel('Ƶ�����/(Hz)')
legend('1','3','6','17','19','22','28')

figure
plot(t,phidot*0.1903)
grid on 