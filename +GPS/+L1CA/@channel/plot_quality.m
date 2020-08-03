function plot_quality(obj)
% ���ź�����

% ���ź�������ǵ�I·���
quality = obj.storage.quality; %�ź�����
I = double(obj.storage.I_Q(:,1)); %I·���
I1 = I;
I1(quality<1) = NaN; %����ǿ�źź����ź�
I2 = I;
I2(quality<2) = NaN; %����ǿ�ź�

PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Position', screenBlock(1000,300,0.5,0.5), 'Name',PRN_str);
axes('Position', [0.05, 0.15, 0.9, 0.75]);
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, I, 'Color',[0.929,0.694,0.125]) %ʧ��,��
hold on
plot(t, I1, 'Color',[0.85,0.325,0.098]) %���ź�,�ٻ�
plot(t, I2, 'Color',[0,0.447,0.741]) %ǿ�ź�,��ɫ
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])

% ���ź�������ǵ��ز�Ƶ��
quality = obj.storage.quality; %�ź�����
fc = obj.storage.carrFreq; %�ز�Ƶ��
fc1 = fc;
fc1(quality<1) = NaN; %����ǿ�źź����ź�
fc2 = fc;
fc2(quality<2) = NaN; %����ǿ�ź�

PRN_str = ['GPS ',sprintf('%d',obj.PRN)];
figure('Position', screenBlock(1000,300,0.5,0.5), 'Name',PRN_str);
axes('Position', [0.05, 0.15, 0.9, 0.75]);
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, fc, 'Color',[0.929,0.694,0.125]) %ʧ��,��
hold on
grid on
plot(t, fc1, 'Color',[0.85,0.325,0.098]) %���ź�,�ٻ�
plot(t, fc2, 'Color',[0,0.447,0.741]) %ǿ�ź�,��ɫ
plot(t, obj.storage.carrNco+1, 'Color',[0.5,0.5,0.5], 'LineStyle','--') %�Ͻ�
plot(t, obj.storage.carrNco-1, 'Color',[0.5,0.5,0.5], 'LineStyle','--') %�½�
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])

end