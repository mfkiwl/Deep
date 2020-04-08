function plot_bias_acc(obj)
% 画加速度计零偏输出
% obj:接收机对象

figure('Name','加计零偏')
switch obj.state
    case 2
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.bias(:,k+3), 'LineWidth',1)
            grid on
        end
    case 3
end

end