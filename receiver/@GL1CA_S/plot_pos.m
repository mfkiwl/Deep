function plot_pos(obj)
% ��λ�����

%% ����ģʽ
if obj.state==1
    figure('Name','λ��')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.pos(:,k))
        grid on
    end
end

%% �����/�����ģʽ
if obj.state==2 || obj.state==3
    figure('Name','λ��')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.satnav(:,k))
        hold on
        grid on
        plot(obj.storage.pos(:,k), 'LineWidth',1)
    end
end

end