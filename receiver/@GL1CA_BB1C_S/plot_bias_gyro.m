function plot_bias_gyro(obj)
% ����������ƫ���

%% �����ģʽ
if obj.state==3
    figure('Name','������ƫ')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.imu(:,k))
        hold on
        grid on
        plot(obj.storage.bias(:,k), 'LineWidth',1)
    end
end

end