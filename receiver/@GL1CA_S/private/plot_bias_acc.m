function plot_bias_acc(obj)
% �����ٶȼ���ƫ���
% obj:���ջ�����

figure('Name','�Ӽ���ƫ')
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