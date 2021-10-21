% ��IMU����Ľ��ٶȺͼ��ٶ�����
t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;

%% ������
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.imu(:,1)/pi*180, 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('x����ٶ�/(��/s)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.imu(:,2)/pi*180, 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('y����ٶ�/(��/s)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.imu(:,3)/pi*180, 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('z����ٶ�/(��/s)')
xlabel('ʱ��/(s)')

%% ���ٶȼ�
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.imu(:,4), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('x����ٶ�/(m/s^2)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.imu(:,5), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('y����ٶ�/(m/s^2)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.imu(:,6), 'LineWidth',1);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('z����ٶ�/(m/s^2)')
xlabel('ʱ��/(s)')