function plot_quality(obj)
% ���ź�����

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Position', screenBlock(1000,600,0.5,0.5), 'Name',PRN_str);
ax1 = axes('Position',[0.06, 0.55, 0.88, 0.4]);
hold(ax1,'on');
grid(ax1,'on')
ax2 = axes('Position',[0.06, 0.08, 0.88, 0.4]);
hold(ax2,'on');
grid(ax2,'on')

t = obj.storage.dataIndex/obj.sampleFreq;

% ���ź�������ǵ�I·���
quality = obj.storage.quality; %�ź�����
I = double(obj.storage.I_Q(:,1)); %I·���
I1 = I;
I1(quality<1) = NaN; %����ǿ�źź����ź�
I2 = I;
I2(quality<2) = NaN; %����ǿ�ź�

plot(ax1, t, I, 'Color',[0.929,0.694,0.125]) %ʧ��,��
plot(ax1, t, I1, 'Color',[0.85,0.325,0.098]) %���ź�,�ٻ�
plot(ax1, t, I2, 'Color',[0,0.447,0.741]) %ǿ�ź�,��ɫ
set(ax1, 'XLim',[0,ceil(obj.Tms/1000)])

% ���ź�������ǵ��ز�Ƶ��
quality = obj.storage.quality; %�ź�����
fc = obj.storage.carrFreq; %�ز�Ƶ��
fc1 = fc;
fc1(quality<1) = NaN; %����ǿ�źź����ź�
fc2 = fc;
fc2(quality<2) = NaN; %����ǿ�ź�

plot(ax2, t, fc, 'Color',[0.929,0.694,0.125]) %ʧ��,��
plot(ax2, t, fc1, 'Color',[0.85,0.325,0.098]) %���ź�,�ٻ�
plot(ax2, t, fc2, 'Color',[0,0.447,0.741]) %ǿ�ź�,��ɫ
plot(ax2, t, obj.storage.carrNco+1, 'Color',[0.5,0.5,0.5], 'LineStyle','--') %�Ͻ�
plot(ax2, t, obj.storage.carrNco-1, 'Color',[0.5,0.5,0.5], 'LineStyle','--') %�½�
set(ax2, 'XLim',[0,ceil(obj.Tms/1000)])

end