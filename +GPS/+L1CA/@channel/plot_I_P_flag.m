function plot_I_P_flag(obj, varargin)
% ��I_Pͼ,�����ر߽��־

if nargin==1
    name_str = ['GPS ',sprintf('%d',obj.PRN)];
elseif ischar(varargin{1})
    name_str = ['GPS ',sprintf('%d',obj.PRN),varargin{1}];
else
    return
end

% �½�figure
figure('Position',screenBlock(1000,300,0.5,0.5), 'Name',name_str)
axes('Position',[0.05, 0.15, 0.9, 0.75])
set(gca, 'Box','on', 'NextPlot','add')
set(gca, 'XLim',[0,ceil(obj.Tms/1000)])

% ��ͼ
t = obj.storage.dataIndex/obj.sampleFreq;
plot(t, double(obj.storage.I_Q(:,1)))

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