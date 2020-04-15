function plot_carrAcc(obj)
% ��ͨ�����ز�Ƶ�ʱ仯��
% obj:ͨ������

PRN_str = ['PRN ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, obj.storage.carrAcc, 'LineWidth',0.5)
set(gca, 'XLim',[1,ceil(obj.Tms/1000)])
grid on

PRN_str = ['PRN ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, cumsum(obj.storage.carrAcc), 'LineWidth',0.5)
set(gca, 'XLim',[1,ceil(obj.Tms/1000)])
grid on

end