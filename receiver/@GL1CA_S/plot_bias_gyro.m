function plot_bias_gyro(obj)
% ����������ƫ���

figure('Name','������ƫ')
switch obj.state
    case {2, 3}
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.imu(:,k))
            hold on
            grid on
            plot(obj.storage.bias(:,k), 'LineWidth',1)
        end
end

end