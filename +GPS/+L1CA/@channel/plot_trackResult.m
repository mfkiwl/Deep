function plot_trackResult(obj)
% �����ٽ��

% ������ͼ����
PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Position',screenBlock(1140,670,0.5,0.5), 'Name',PRN_str);
ax1 = axes('Position',[0.08, 0.4, 0.38, 0.53]);
hold(ax1,'on');
axis(ax1,'equal');
title(PRN_str)
ax2 = axes('Position',[0.53, 0.7 , 0.42, 0.25]);
hold(ax2,'on');
ax3 = axes('Position',[0.53, 0.38, 0.42, 0.25]);
hold(ax3,'on');
grid(ax3,'on');
ax4 = axes('Position',[0.53, 0.06, 0.42, 0.25]);
hold(ax4,'on');
grid(ax4,'on');
ax5 = axes('Position',[0.05, 0.06, 0.42, 0.25]);
hold(ax5,'on');
grid(ax5,'on');

t = obj.storage.dataIndex/obj.sampleFreq; %ʹ�ò���������ʱ��

% I/Qͼ
plot(ax1, obj.storage.I_Q(1001:end,1), obj.storage.I_Q(1001:end,4), ...
          'LineStyle','none', 'Marker','.')

% I_Pͼ
plot(ax2, t, double(obj.storage.I_Q(:,1))) %����������������Ҫһ��
set(ax2, 'XLim',[0,ceil(obj.Tms/1000)])

% �����
index = isnan(obj.storage.dataIndex) | obj.storage.bitFlag~=0; %��Ч���ݵ�����
plot(ax3, t(index), obj.storage.CN0(index), 'LineWidth',1)
set(ax3, 'XLim',[0,ceil(obj.Tms/1000)])
set(ax3, 'YLim',[0,60])

% �ز�Ƶ��
plot(ax4, t, obj.storage.carrFreq, 'LineWidth',0.5)
set(ax4, 'XLim',[0,ceil(obj.Tms/1000)])

% �ز�Ƶ�ʱ仯��
plot(ax5, t, obj.storage.carrAcc, 'LineWidth',0.5)
set(ax5, 'XLim',[0,ceil(obj.Tms/1000)])

end