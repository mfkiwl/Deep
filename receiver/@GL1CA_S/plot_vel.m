function plot_vel(obj)
% ���ٶ����

%% ����ģʽ
if obj.state==1
    figure('Name','�ٶ�')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.vel(:,k))
        grid on
    end
end

%% �����/�����ģʽ
if obj.state==2 || obj.state==3
    figure('Name','�ٶ�')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.satnav(:,k+3))
        hold on
        grid on
        plot(obj.storage.vel(:,k), 'LineWidth',1)
    end
end

end