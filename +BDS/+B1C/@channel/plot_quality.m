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
CN0 = obj.storage.CN0; %�����

% ���ź�������ǵ�I·���
I0 = double(obj.storage.I_Q(:,1)); %I·���
I1 = I0;
I1(CN0<18) = NaN;
I2 = I0;
I2(CN0<24) = NaN;
I3 = I0;
I3(CN0<37) = NaN;

plot(ax1, t, I0, 'Color',[0.466,0.674,0.188]) %ʧ��,��
plot(ax1, t, I1, 'Color',[0.929,0.694,0.125]) %�����ź�,��
plot(ax1, t, I2, 'Color',[0.850,0.325,0.098]) %���ź�,�ٻ�
plot(ax1, t, I3, 'Color',[    0,0.447,0.741]) %ǿ�ź�,��ɫ
set(ax1, 'XLim',[0,ceil(obj.Tms/1000)])

% ���ź�������ǵ��ز�Ƶ��
fc0 = obj.storage.carrFreq; %�ز�Ƶ��
fc1 = fc0;
fc1(CN0<18) = NaN;
fc2 = fc0;
fc2(CN0<24) = NaN;
fc3 = fc0;
fc3(CN0<37) = NaN;

plot(ax2, t, fc0, 'Color',[0.466,0.674,0.188]) %ʧ��,��
plot(ax2, t, fc1, 'Color',[0.929,0.694,0.125]) %�����ź�,��
plot(ax2, t, fc2, 'Color',[0.850,0.325,0.098]) %���ź�,�ٻ�
plot(ax2, t, fc3, 'Color',[    0,0.447,0.741]) %ǿ�ź�,��ɫ
plot(ax2, t, obj.storage.carrNco+1, 'Color',[0.5,0.5,0.5], 'LineStyle','--') %�Ͻ�
plot(ax2, t, obj.storage.carrNco-1, 'Color',[0.5,0.5,0.5], 'LineStyle','--') %�½�
set(ax2, 'XLim',[0,ceil(obj.Tms/1000)])

end