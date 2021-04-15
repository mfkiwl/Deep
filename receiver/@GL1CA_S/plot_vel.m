function plot_vel(obj)
% ���ٶ����

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

% �����ǵ���������
figure('Name','�ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t, obj.storage.satnav(:,k+3))
    hold on
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
end

% �˲����
if obj.state==2 || obj.state==3 || obj.state==4
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.vel(:,k), 'LineWidth',0.5)
    end
    figure('Name','�ٶ����')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.satnav(:,k+3)-obj.storage.vel(:,k))
        grid on
    end
end

end