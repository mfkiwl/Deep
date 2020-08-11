function plot_bias_gyro(obj)
% ����������ƫ���

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

%% �����ģʽ
if obj.state==3
    figure('Name','������ƫ')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.imu(:,k))
        hold on
        grid on
        plot(t, obj.storage.bias(:,k), 'LineWidth',1)
        set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    end
end

end