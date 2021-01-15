function plot_freqDisc(obj)
% ����Ƶ�����

PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
index = find(isnan(obj.storage.dataIndex) | ~isnan(obj.storage.disc(:,3))); %��Ч���ݵ�����
t = obj.storage.dataIndex(index)/obj.sampleFreq;
plot(t, obj.storage.disc(index,3))
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
grid on

end