function plot_I_P_flag(obj)
% ��I_Pͼ(���ݷ���),�����ؿ�ʼ��־

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Position', screenBlock(1000,300,0.5,0.5), 'Name',PRN_str);
axes('Position', [0.05, 0.15, 0.9, 0.75]);
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(:,7)))
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
hold on

% ���֡ͬ���׶�(��ɫ)
index = obj.storage.bitFlag=='F';
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(index,7)), 'LineStyle','none', 'Marker','.', 'Color','m')

% ��ǵȴ�֡ͷ�׶�(��ɫ)
index = obj.storage.bitFlag=='H';
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(index,7)), 'LineStyle','none', 'Marker','.', 'Color','b')

% ��ǽ��������׶�(��ɫ),ǰ6������Ϊ���Ǳ��
index = obj.storage.bitFlag=='E';
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(index,7)), 'LineStyle','none', 'Marker','.', 'Color','r')

end