function plot_svnum(obj)
% ���ɼ���������

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

figure('Name','�ɼ���������')
plot(t, obj.result.svnum(:,2),  'LineWidth',1)
grid on
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
set(gca, 'YLim',[0,max(obj.result.svnum(:,2))+1])

end