function plot_I_P_flag(obj)
% ��I_Pͼ,�����ر߽��־

PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Position', screenBlock(1000,300,0.5,0.5), 'Name',PRN_str);
axes('Position', [0.05, 0.15, 0.9, 0.75]);
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(:,1)))
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
hold on

% ���Ѱ��֡ͷ�׶�(��ɫ),�ý׶εĽ�βһ����[1,0,0,0,1,0,1,1]
index = obj.storage.bitFlag=='H';
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(index,1)), 'LineStyle','none', 'Marker','.', 'Color','m')

% ���У��֡ͷ�׶�(��ɫ),�ý׶εĽ�βһ����[1,0,0,0,1,0,1,1]
index = obj.storage.bitFlag=='C';
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(index,1)), 'LineStyle','none', 'Marker','.', 'Color','b')

% ��ǽ��������׶�(��ɫ)
index = obj.storage.bitFlag=='E';
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(index,1)), 'LineStyle','none', 'Marker','.', 'Color','r')

end