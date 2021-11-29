function plot_bias_acc(obj)
% �����ٶȼ���ƫ���

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

if obj.state==2 || obj.state==3
    figure('Name','�Ӽ���ƫ')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.bias(:,k+3), 'LineWidth',1)
        grid on
        set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    end
end

end