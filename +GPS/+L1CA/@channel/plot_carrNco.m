function plot_carrNco(obj, varargin)
% ���ز�����Ƶ��

if nargin==1
    name_str = ['GPS ',sprintf('%d',obj.PRN)];
elseif ischar(varargin{1})
    name_str = ['GPS ',sprintf('%d',obj.PRN),varargin{1}];
else
    return
end

% �½�figure
figure('Name',name_str)
axes('Box','on', 'NextPlot','add')
grid on
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])

% ��ͼ
t = obj.storage.dataIndex/obj.sampleFreq;
if obj.state==3 %ʸ������ʱ���Ƶ��ز�Ƶ����Ϊ����
    plot(t, obj.storage.carrFreq)
    plot(t, obj.storage.carrNco)
    legend('���Ƶ��ز�Ƶ��','����Ƶ��')
else %�����������Ƶ����Ϊ����
    plot(t, obj.storage.carrNco)
    plot(t, obj.storage.carrFreq)
    legend('����Ƶ��','���Ƶ��ز�Ƶ��')
end

end