function plot_carrFreq(obj)
% ���ز�Ƶ��

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, obj.storage.carrFreq)
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
grid on

end