function plot_att(obj)
% ����̬���
% obj:���ջ�����

figure('Name','��̬')
switch obj.state
    case 2
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.att(:,k), 'LineWidth',1)
            grid on
        end
    case 3
end

end