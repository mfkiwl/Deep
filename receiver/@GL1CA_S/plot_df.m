function plot_df(obj)
% ����Ƶ�����ֵ

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

figure('Name','��Ƶ�����')
plot(t, obj.storage.df)
grid on
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])

end