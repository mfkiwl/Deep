function plot_bias_acc(obj)
% �����ٶȼ���ƫ���

%% �����ģʽ
if obj.state==3
    figure('Name','�Ӽ���ƫ')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.bias(:,k+3), 'LineWidth',1)
        grid on
    end
end

end