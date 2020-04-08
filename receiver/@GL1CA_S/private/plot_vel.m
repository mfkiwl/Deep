function plot_vel(obj)
% ���ٶ����
% obj:���ջ�����

figure('Name','�ٶ�')
switch obj.state
    case 1
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.vel(:,k))
            grid on
        end
    case 2
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.satnav(:,k+3))
            hold on
            grid on
            plot(obj.storage.vel(:,k), 'LineWidth',1)
        end
    case 3
end

end