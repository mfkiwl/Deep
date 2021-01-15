function plot_carrAcc(obj)
% ���ز�Ƶ�ʱ仯��

PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Position',screenBlock(900,540,0.5,0.5), 'Name',PRN_str);
ax1 = axes('Position',[0.07, 0.55, 0.4, 0.38]); %(1,1)
hold(ax1,'on');
grid(ax1,'on');
ax2 = axes('Position',[0.54, 0.55, 0.4, 0.38]); %(1,2)
hold(ax2,'on');
grid(ax2,'on');
ax3 = axes('Position',[0.07, 0.08, 0.4, 0.38]); %(2,1)
hold(ax3,'on');
grid(ax3,'on');
ax4 = axes('Position',[0.54, 0.08, 0.4, 0.38]); %(2,2)
hold(ax4,'on');
grid(ax4,'on');

t = obj.storage.dataIndex/obj.sampleFreq;
dt = [diff(t); 0];
carrAccInt = cumsum(obj.storage.carrAcc.*dt); %�ز����ٶȻ���ֵ

plot(ax1, t, obj.storage.carrAcc)
set(ax1, 'XLim',[0,ceil(obj.Tms/1000)])
title(ax1, '�ز����ٶ�')
plot(ax2, t, carrAccInt)
set(ax2, 'XLim',[0,ceil(obj.Tms/1000)])
title(ax2, '�ز����ٶȻ���ֵ')
plot(ax4, t, obj.storage.carrFreq)
set(ax4, 'XLim',[0,ceil(obj.Tms/1000)])
title(ax4, '�ز�Ƶ��')
plot(ax3, t, obj.storage.carrFreq-carrAccInt)
set(ax3, 'XLim',[0,ceil(obj.Tms/1000)])
title(ax3, '�������')
% ������������һ��ƽ��ֱ��,���б��Ư��ʱ��Ư��

end