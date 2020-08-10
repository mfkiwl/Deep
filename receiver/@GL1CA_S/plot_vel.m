function plot_vel(obj)
% ���ٶ����

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

%% ����ģʽ
if obj.state==1
    figure('Name','�ٶ�')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.vel(:,k))
        grid on
    end
end

%% �����/�����ģʽ
if obj.state==2 || obj.state==3
    figure('Name','�ٶ�')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.satnav(:,k+3))
        hold on
        grid on
        plot(t, obj.storage.vel(:,k), 'LineWidth',1)
    end
end

end