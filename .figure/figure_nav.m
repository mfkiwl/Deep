% ���������

%% λ��
t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.pos(:,1), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('γ��/(��)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.pos(:,2), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('����/(��)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.pos(:,3), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�߶�/(m)')
xlabel('ʱ��/(s)')

%% �ٶ�
t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.vel(:,1), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ�/(m/s)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.vel(:,2), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ�/(m/s)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.vel(:,3), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����ٶ�/(m/s)')
xlabel('ʱ��/(s)')

%% ��̬
t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, attContinuous(nCoV.storage.att(:,1)), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('�����/(��)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.att(:,2), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('������/(��)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.att(:,3), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('��ת��/(��)')
xlabel('ʱ��/(s)')

%% ��������ƫ����ֵ
t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.bias(:,1)/pi*180, 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('x��������ƫ/(��/s)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.bias(:,2)/pi*180, 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('y��������ƫ/(��/s)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.bias(:,3)/pi*180, 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('z��������ƫ/(��/s)')
xlabel('ʱ��/(s)')

%% ���ٶȼ���ƫ����ֵ
t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.bias(:,4), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('x��Ӽ���ƫ/(m/s^2)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.bias(:,5), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('y��Ӽ���ƫ/(m/s^2)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.bias(:,6), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('z��Ӽ���ƫ/(m/s^2)')
xlabel('ʱ��/(s)')