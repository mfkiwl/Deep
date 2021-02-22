function plot_att(obj)
% ����̬���

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

if obj.state==2 || obj.state==3
    figure('Name','��̬')
%     for k=1:3
%         subplot(3,1,k)
%         plot(t, obj.storage.att(:,k), 'LineWidth',0.5)
%         grid on
%         set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
%     end
    subplot(3,1,1)
    plot(t, attContinuous(obj.storage.att(:,1)), 'LineWidth',0.5)
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    subplot(3,1,2)
    plot(t, obj.storage.att(:,2), 'LineWidth',0.5)
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    subplot(3,1,3)
    plot(t, obj.storage.att(:,3), 'LineWidth',0.5)
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
end

end