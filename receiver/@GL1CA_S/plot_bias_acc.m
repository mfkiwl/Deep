function plot_bias_acc(obj)
% �����ٶȼ���ƫ���

figure('Name','�Ӽ���ƫ')
switch obj.state
    case {2, 3}
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.bias(:,k+3), 'LineWidth',1)
            grid on
        end
end

end