% ������ϵ�µļ��ٶ�

t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;
figure('Position',[488,200,560,520])

ax = subplot(3,1,1);
h = plot(t, nCoV.storage.others(:,10), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('������ٶ�/(m/s^2)')

ax = subplot(3,1,2);
h = plot(t, nCoV.storage.others(:,11), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('������ٶ�/(m/s^2)')

ax = subplot(3,1,3);
h = plot(t, nCoV.storage.others(:,12), 'LineWidth',1.5);
grid on
set(ax, 'FontSize',12)
set(ax, 'xlim',[t(1),t(end)])
figureMargin(ax, h, 0.2);
ylabel('������ٶ�/(m/s^2)')
xlabel('ʱ��/(s)')