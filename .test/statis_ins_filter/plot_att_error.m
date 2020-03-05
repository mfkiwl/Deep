function plot_att_error(t, data, sigma)
% data;��̬�����,deg
% sigma:rad

data = mod(data+180,360)-180; %��̬���ת����180
sigma = sigma/pi*180 *3;

figure('Name','��̬���')

subplot(3,1,1)
hold on
grid on
plot(t, data(:,1), 'LineWidth',2)
axis manual
plot(t,  sigma(:,1), 'Color','r', 'LineStyle','--')
plot(t, -sigma(:,1), 'Color','r', 'LineStyle','--')
set(gca, 'xlim', [t(1),t(end)])
xlabel('\itt\rm(s)')
ylabel('\delta\psi(\circ)')

subplot(3,1,2)
hold on
grid on
plot(t, data(:,2), 'LineWidth',2)
axis manual
plot(t,  sigma(:,2), 'Color','r', 'LineStyle','--')
plot(t, -sigma(:,2), 'Color','r', 'LineStyle','--')
set(gca, 'xlim', [t(1),t(end)])
xlabel('\itt\rm(s)')
ylabel('\delta\theta(\circ)')

subplot(3,1,3)
hold on
grid on
plot(t, data(:,3), 'LineWidth',2)
axis manual
plot(t,  sigma(:,3), 'Color','r', 'LineStyle','--')
plot(t, -sigma(:,3), 'Color','r', 'LineStyle','--')
set(gca, 'xlim', [t(1),t(end)])
xlabel('\itt\rm(s)')
ylabel('\delta\gamma(\circ)')

end