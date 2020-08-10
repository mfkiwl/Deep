function plot_carrDisc(obj)
% ���ز����������

PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, obj.storage.disc(:,2))
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
grid on
hold on
plot(t, obj.storage.disc(:,5))
plot(t, obj.storage.disc(:,5)*3)

end