function plot_carrNco(obj)
% ���ز�����Ƶ��

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
t = obj.storage.dataIndex/obj.sampleFreq;
if obj.state==3 %�����ʱ���Ƶ��ز�Ƶ����Ϊ����
    plot(t, obj.storage.carrFreq)
    hold on
    plot(t, obj.storage.carrNco)
    legend('���Ƶ��ز�Ƶ��','����Ƶ��')
else %�����������Ƶ����Ϊ����
    plot(t, obj.storage.carrNco)
    hold on
    plot(t, obj.storage.carrFreq)
    legend('����Ƶ��','���Ƶ��ز�Ƶ��')
end
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
grid on

end