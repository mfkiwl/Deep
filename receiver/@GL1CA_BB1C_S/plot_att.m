function plot_att(obj)
% ����̬���

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

%% �����ģʽ
if obj.state==3
    figure('Name','��̬')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.att(:,k), 'LineWidth',1)
        grid on
        set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    end
end

end