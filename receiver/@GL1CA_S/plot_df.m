function plot_df(obj)
% ����Ƶ�����ֵ

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

figure('Name','��Ƶ�����')
plot(t, obj.storage.df)
grid on
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])

if obj.state==3
    figure('Name','�Ӳ���Ƶ��')
    subplot(2,1,1)
    plot(t, [obj.storage.satnav(:,7),obj.storage.others(:,8)])
    grid on
    subplot(2,1,2)
    plot(t, [obj.storage.satnav(:,8),obj.storage.others(:,9)])
    grid on
end

end