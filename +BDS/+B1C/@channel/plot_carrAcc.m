function plot_carrAcc(obj)
% ���ز�Ƶ�ʱ仯��

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, obj.storage.carrAcc, 'LineWidth',0.5)
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
grid on
title('�ز����ٶ�')

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, cumsum(obj.storage.carrAcc), 'LineWidth',0.5)
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
grid on
title('�ز����ٶȵĻ���')

end