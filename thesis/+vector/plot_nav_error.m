% ��������ջ�����еĵ������,�����Ǵ���������Ƶ����

% ����Ƿ��Ƿ�������
[~,name,~] = fileparts(data_file); %�ļ������
prefix = strtok(name, '_');
if ~strcmp(prefix,'SIM') %���Ƿ������ݷ���
    return
end

% ���ع켣����
trajnum = name(21:23); %�켣���
load(['~temp\traj\traj',trajnum])
dt_traj = trajGene_conf.dt; %�켣�������
dt_pos = nCoV.dtpos/1000; %���ջ��������
m = dt_pos / dt_traj; %������

% ���ɹ켣��ʱ������
startTime_gps = UTC2GPS(tf, 8); %��ʼ��GPSʱ��
tow = startTime_gps(2); %������
n = size(traj,1);
time = tow + (0:n-1)'*dt_traj;

% ����
n1 = find(time==nCoV.storage.ta(1),1);
n2 = find(time==nCoV.storage.ta(end),1);

t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;

%% λ��
pos_real = traj(n1:m:n2,7:9); %��ʵλ��
pos_error = nCoV.storage.pos - pos_real; %λ�����
% pos_error = nCoV.storage.satnav(:,1:3) - pos_real; %���ǵ�����

figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, pos_error(:,1)/180*pi/nCoV.geogInfo.dlatdn, 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('����λ�����/(m)')

ax = subplot(3,1,2);
h = plot(t, pos_error(:,2)/180*pi/nCoV.geogInfo.dlonde, 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('����λ�����/(m)')

ax = subplot(3,1,3);
h = plot(t, pos_error(:,3), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�߶����/(m)')
xlabel('ʱ��/(s)')

%% �ٶ�
vel_real = traj(n1:m:n2,10:12); %��ʵ�ٶ�
vel_error = nCoV.storage.vel - vel_real; %�ٶ����
% vel_error = nCoV.storage.satnav(:,4:6) - vel_real; %���ǵ�����

figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, vel_error(:,1), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ����/(m/s)')

ax = subplot(3,1,2);
h = plot(t, vel_error(:,2), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ����/(m/s)')

ax = subplot(3,1,3);
h = plot(t, vel_error(:,3), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ����/(m/s)')
xlabel('ʱ��/(s)')