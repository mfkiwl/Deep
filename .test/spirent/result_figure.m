% ��һЩ����������

%% �������
trec = time*[1;1e-3;1e-6] - t0; %����ʱ������

% ��ɫ��
newcolors = [   0, 0.447, 0.741;
            0.850, 0.325, 0.098;
            0.929, 0.694, 0.125;
            0.494, 0.184, 0.556;
            0.466, 0.674, 0.188;
            0.301, 0.745, 0.933;
            0.635, 0.078, 0.184;
                1, 0.075, 0.651;
                1,     0,     0;
                0,     0,     1];

figure('Name','�����')
colororder(newcolors) %������ɫ��
ax = axes;
ax.Box = 'on';
hold on
grid on

for k=1:32
    if any(~isnan(CN0(:,k)))
        plot(trec,CN0(:,k),  'LineWidth',1, 'DisplayName',['PRN ',num2str(k)])
    end
end

set(ax, 'FontSize',12)
set(ax, 'XLim',[trec(1),trec(end)])
set(ax, 'YLim',[10,55])
xlabel('ʱ��/(s)')
ylabel('�����/(dB��Hz)')
legend('Location','southeast')

%% ���ز�Ƶ�ʱ仯��(carrAccR)
% ��������������Ƶ���ȶ�,����PLL���Ƴ��ĸ�ͨ�����ز����ٶ��ǲ���ص�(���������֤)
% ��ʵ�ʽ��ջ��������з���,��ͨ�����ز����ٶ���һ�������,˵��ʵ�ʾ����Ƶ�ʲ��ȶ�,�����Խǿ,����Խ��
trec = time*[1;1e-3;1e-6] - t0; %����ʱ������

% ��ɫ��
newcolors = [   0, 0.447, 0.741;
            0.850, 0.325, 0.098;
            0.929, 0.694, 0.125;
            0.494, 0.184, 0.556;
            0.466, 0.674, 0.188;
            0.301, 0.745, 0.933;
            0.635, 0.078, 0.184;
                1, 0.075, 0.651;
                1,     0,     0;
                0,     0,     1];

figure('Name','�ز�Ƶ�ʱ仯��(carrAccR)')
colororder(newcolors) %������ɫ��
ax = axes;
ax.Box = 'on';
hold on
grid on

for k=1:32
    if any(~isnan(carrAccR(:,k)))
        plot(trec,carrAccR(:,k),  'LineWidth',1, 'DisplayName',['PRN ',num2str(k)])
    end
end

set(ax, 'FontSize',12)
set(ax, 'XLim',[trec(1),trec(end)])
xlabel('ʱ��/(s)')
ylabel('�ز�Ƶ�ʱ仯��/(Hz/s)')
legend('Location','southeast')

%% ���켣���ٶȺͼ��ٶ�����
tsim = motionSim(:,1) - t0;

figure
subplot(3,1,1)
plot(tsim,motionSim(:,5), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[tsim(1),tsim(end)])
ylabel('\itv\rm_N/(m/s)')

subplot(3,1,2)
plot(tsim,motionSim(:,6), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[tsim(1),tsim(end)])
ylabel('\itv\rm_E/(m/s)')

subplot(3,1,3)
plot(tsim,motionSim(:,7), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[tsim(1),tsim(end)])
ylabel('\itv\rm_D/(m/s)')
xlabel('ʱ��/(s)')

figure
subplot(3,1,1)
plot(tsim,motionSim(:,8), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[tsim(1),tsim(end)])
ylabel('\ita\rm_N/(m/s^2)')

subplot(3,1,2)
plot(tsim,motionSim(:,9), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[tsim(1),tsim(end)])
ylabel('\ita\rm_E/(m/s^2)')

subplot(3,1,3)
plot(tsim,motionSim(:,10), 'LineWidth',1.5)
grid on
ax = gca;
set(ax, 'FontSize',12)
set(ax, 'XLim',[tsim(1),tsim(end)])
ylabel('\ita\rm_D/(m/s^2)')
xlabel('ʱ��/(s)')