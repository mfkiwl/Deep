% ��GPS+BDS�ɼ���������

t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;

figure
ax = subplot(3,1,1);
plot(t, nCoV.result.svnumGPS(:,2))
grid on
set(ax, 'FontSize',10.5)
set(ax, 'xlim',[t(1),t(end)])
ylabel('GPS��������')

ax = subplot(3,1,2);
plot(t, nCoV.result.svnumBDS(:,2))
grid on
set(ax, 'FontSize',10.5)
set(ax, 'xlim',[t(1),t(end)])
ylabel('BDS��������')

ax = subplot(3,1,3);
plot(t, nCoV.result.svnumALL(:,2))
grid on
set(ax, 'FontSize',10.5)
set(ax, 'xlim',[t(1),t(end)])
ylabel('GPS+BDS��������')
xlabel('ʱ��/(s)')