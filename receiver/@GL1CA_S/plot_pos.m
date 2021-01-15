function plot_pos(obj)
% ��λ�����

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

% �����ǵ���������
figure('Name','λ��')
for k=1:3
    subplot(3,1,k)
    plot(t, obj.storage.satnav(:,k))
    hold on
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
end

% �˲����
if obj.state==2 || obj.state==3
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.pos(:,k), 'LineWidth',1)
    end
end

end