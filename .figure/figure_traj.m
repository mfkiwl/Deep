% ���켣���������������۹켣
% ִ��trajGene.m������

%% λ��
t = (0:size(traj,1)-1)*trajGene_conf.dt;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, traj(:,7), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('γ��/(��)')

ax = subplot(3,1,2);
h = plot(t, traj(:,8), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('����/(��)')

ax = subplot(3,1,3);
h = plot(t, traj(:,9), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�߶�/(m)')
xlabel('ʱ��/(s)')

%% �ٶ�
t = (0:size(traj,1)-1)*trajGene_conf.dt;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, traj(:,10), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ�/(m/s)')

ax = subplot(3,1,2);
h = plot(t, traj(:,11), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ�/(m/s)')

ax = subplot(3,1,3);
h = plot(t, traj(:,12), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ�/(m/s)')
xlabel('ʱ��/(s)')

%% ��̬
t = (0:size(traj,1)-1)*trajGene_conf.dt;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, attContinuous(traj(:,4)), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����/(��)')

ax = subplot(3,1,2);
h = plot(t, traj(:,5), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('������/(��)')

ax = subplot(3,1,3);
h = plot(t, traj(:,6), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('��ת��/(��)')
xlabel('ʱ��/(s)')

%% ���ٶ�
t = (0:size(traj,1)-1)*trajGene_conf.dt;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, traj(:,13), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('x����ٶ�/(��/s)')

ax = subplot(3,1,2);
h = plot(t, traj(:,14), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('y����ٶ�/(��/s)')

ax = subplot(3,1,3);
h = plot(t, traj(:,15), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('z����ٶ�/(��/s)')
xlabel('ʱ��/(s)')

%% ���ٶ�
t = (0:size(traj,1)-1)*trajGene_conf.dt;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, traj(:,16), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('x����ٶ�/(m/s^2)')

ax = subplot(3,1,2);
h = plot(t, traj(:,17), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('y����ٶ�/(m/s^2)')

ax = subplot(3,1,3);
h = plot(t, traj(:,18), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('z����ٶ�/(m/s^2)')
xlabel('ʱ��/(s)')