function plot_att(obj)
% ����̬���

%% �����ģʽ
if obj.state==3
    figure('Name','��̬')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.att(:,k), 'LineWidth',1)
        grid on
    end
end

end