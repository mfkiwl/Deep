% �켣�����������ͼ
% �켣������Ϊtraj

t = (0:size(traj,1)-1)*trajGene_conf.dt; %ʱ������

%----λ��
figure
subplot(3,1,1)
plot(t, traj(:,7), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
title('λ��')
subplot(3,1,2)
plot(t, traj(:,8), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,1,3)
plot(t, traj(:,9), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])

%----�ٶ�
figure
subplot(3,1,1)
plot(t, traj(:,10), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
title('�ٶ�')
subplot(3,1,2)
plot(t, traj(:,11), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,1,3)
plot(t, traj(:,12), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])

%----��̬
figure
subplot(3,1,1)
plot(t, traj(:,4), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
title('��̬')
subplot(3,1,2)
plot(t, traj(:,5), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,1,3)
plot(t, traj(:,6), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])

%----���ٶ�&���ٶ�
figure
subplot(3,2,1)
plot(t, traj(:,13), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,2,3)
plot(t, traj(:,14), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,2,5)
plot(t, traj(:,15), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,2,2)
plot(t, traj(:,16), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,2,4)
plot(t, traj(:,17), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])
subplot(3,2,6)
plot(t, traj(:,18), 'LineWidth',1)
grid on
set(gca, 'xlim', [t(1),t(end)])

clearvars t