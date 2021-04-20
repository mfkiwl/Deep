%% �������ǵ����˲���(��ֹ���)

%%
clear
clc

%% ����ʱ��
T = 500;       %��ʱ��
dt = 1;        %ʱ����
n = T / dt;    %�������
t = (1:n)'*dt; %ʱ������,������

%% ���ջ�ָ��
sigma_rho = 3; %m
sigma_rhodot = 0.04; %m/s
dtr = 1e-8; %��ʼ�Ӳ�,s
dtv = 3e-9; %��Ƶ��,s/s
c = 299792458;

%% λ��
p0 = [46, 126, 200];
rp = lla2ecef(p0);

%% ����λ��
% ��һ��Ϊ��λ��,�ڶ���Ϊ�߶Ƚ�,deg
sv_info = [  0, 45;
            23, 28;
            58, 80;
           100, 49;
           146, 34;
           186, 78;
           213, 43;
           255, 15;
           310, 20];
rho = 20000000; %���ǵ����ջ��ľ���,m

%% ��������λ���ٶ�
svN = size(sv_info,1); %���Ǹ���
sv_real = zeros(svN,8);
G = zeros(svN,4);
G(:,4) = -1;
Cen = dcmecef2ned(p0(1), p0(2));
for k=1:svN
    e = [-cosd(sv_info(k,2))*cosd(sv_info(k,1)), ...
         -cosd(sv_info(k,2))*sind(sv_info(k,1)), ...
          sind(sv_info(k,2))]; %����ָ����ջ��ĵ�λʸ��
	rsp = e * rho; %����ָ����ջ���λ��ʸ��
    sv_real(k,1:3) = rp - (rsp*Cen); %����λ��
    sv_real(k,4:6) = 0; %�����ٶ�
    sv_real(k,7) = rho; %α��
    sv_real(k,8) = 0; %α����
    G(k,1:3) = e;
end
D = inv(G'*G);
sqrt(diag(D)) %��������

%% �������洢�ռ�
output.satnav = zeros(n,8); %���ǵ���������
output.filter = zeros(n,11); %�˲����
output.dt = zeros(n,1); %�Ӳ�
output.df = zeros(n,1); %��Ƶ��
output.P = zeros(n,11);

%% ��ʼ�������˲���
para.dt = dt;
para.p0 = p0;
para.v0 = [0,0,0];
para.P0_pos = 5; %m
para.P0_vel = 1; %m/s
para.P0_acc = 1; %m/s^2
para.P0_dtr = 2e-8; %s
para.P0_dtv = 3e-9; %s/s
para.Q_pos = 0;
para.Q_vel = 0;
para.Q_acc = 1e-4; %ʱ������ʱ,��������ܴ�
para.Q_dtr = 0;
para.Q_dtv = 1e-9;
NF = filter_sat(para);

%% ��ʼ����
for k=1:n
    % ������������
    dtr = dtr + dtv*dt; %��ǰ�Ӳ�
    sv = sv_real;
    sv(:,7) = sv(:,7) + randn(svN,1)*sigma_rho + dtr*c;
    sv(:,8) = sv(:,8) + randn(svN,1)*sigma_rhodot + dtv*c;
    sv(:,9) = sigma_rho^2;
    sv(:,10) = sigma_rhodot^2;
    
    % ���ǵ�������
    satnav = satnavSolve(sv, rp);
    
    % �����˲�
    NF.run(sv, true(svN,1), true(svN,1));
    
    % �洢���
    output.satnav(k,:) = satnav([1,2,3,7,8,9,13,14]);
    output.filter(k,:) = [NF.pos, NF.vel, NF.acc, NF.dtr, NF.dtv];
    output.dt(k) = dtr;
    output.df(k) = dtv;
    output.P(k,:) = sqrt(diag(NF.P));
end

%% ��λ�����
r2d = 180/pi;
figure('Name','λ��')

subplot(3,1,1)
plot(t, output.satnav(:,1))
hold on
grid on
axis manual
plot(t, output.filter(:,1), 'LineWidth',1)
plot(t, p0(1)+output.P(:,1)*NF.geogInfo.dlatdn*r2d*3, 'Color','k', 'LineStyle','--')
plot(t, p0(1)-output.P(:,1)*NF.geogInfo.dlatdn*r2d*3, 'Color','k', 'LineStyle','--')
set(gca, 'xlim', [0,t(end)])

subplot(3,1,2)
plot(t, output.satnav(:,2))
hold on
grid on
axis manual
plot(t, output.filter(:,2), 'LineWidth',1)
plot(t, p0(2)+output.P(:,2)*NF.geogInfo.dlonde*r2d*3, 'Color','k', 'LineStyle','--')
plot(t, p0(2)-output.P(:,2)*NF.geogInfo.dlonde*r2d*3, 'Color','k', 'LineStyle','--')
set(gca, 'xlim', [0,t(end)])

subplot(3,1,3)
plot(t, output.satnav(:,3))
hold on
grid on
axis manual
plot(t, output.filter(:,3), 'LineWidth',1)
plot(t, p0(3)+output.P(:,3)*3, 'Color','k', 'LineStyle','--')
plot(t, p0(3)-output.P(:,3)*3, 'Color','k', 'LineStyle','--')
set(gca, 'xlim', [0,t(end)])

%% ���ٶ����
figure('Name','�ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t, output.satnav(:,k+3))
    hold on
    grid on
    axis manual
    plot(t, output.filter(:,k+3), 'LineWidth',1)
    plot(t,  output.P(:,k+3)*3, 'Color','k', 'LineStyle','--')
    plot(t, -output.P(:,k+3)*3, 'Color','k', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end

%% �����ٶ�
figure('Name','���ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t, output.filter(:,k+6), 'LineWidth',1)
    hold on
    grid on
    axis manual
    plot(t,  output.P(:,k+6)*3, 'Color','r', 'LineStyle','--')
    plot(t, -output.P(:,k+6)*3, 'Color','r', 'LineStyle','--')
    set(gca, 'xlim', [0,t(end)])
end

%% ���Ӳ�
figure('Name','�Ӳ�')
subplot(2,1,1)
plot(t, output.dt-output.filter(:,10), 'LineWidth',1)
grid on
set(gca, 'xlim', [0,t(end)])

subplot(2,1,2)
plot(t, output.satnav(:,8))
hold on
grid on
plot(t, output.filter(:,11))
set(gca, 'xlim', [0,t(end)])