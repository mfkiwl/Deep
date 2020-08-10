function plot_pos(obj)
% ��λ�����

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

%% ����ģʽ
if obj.state==1
    figure('Name','λ��')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.pos(:,k))
        grid on
    end
end

%% �����/�����ģʽ
if obj.state==2 || obj.state==3
    figure('Name','λ��')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.satnav(:,k))
        hold on
        grid on
        plot(t, obj.storage.pos(:,k), 'LineWidth',1)
    end
end

end