function varargout = plot_trackResult(obj, varargin)
% �����ٽ��

flag = 1;
if nargin==1
    name_str = ['GPS ',sprintf('%d',obj.PRN)];
elseif ischar(varargin{1})
    name_str = ['GPS ',sprintf('%d',obj.PRN),varargin{1}];
elseif isgraphics(varargin{1})
    f = varargin{1};
    flag = 0;
else
    return
end

% �½�figure
if flag==1
    f = figure('Position',screenBlock(1140,670,0.5,0.5), 'Name',name_str);
    axes('Position',[0.08, 0.4, 0.38, 0.53]) %(1,1)
    set(gca, 'Box','on', 'NextPlot','add')
    axis equal
    title(name_str)
    axes('Position',[0.53, 0.7 , 0.42, 0.25]) %(1,2)
    set(gca, 'Box','on', 'NextPlot','add')
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    title('I_P')
    axes('Position',[0.53, 0.38, 0.42, 0.25]) %(2,2)
    set(gca, 'Box','on', 'NextPlot','add')
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    set(gca, 'YLim',[0,60])
    title('�����')
    axes('Position',[0.53, 0.06, 0.42, 0.25]) %(3,2)
    set(gca, 'Box','on', 'NextPlot','add')
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    title('�ز�Ƶ��')
    axes('Position',[0.05, 0.06, 0.42, 0.25]) %(2,1)
    set(gca, 'Box','on', 'NextPlot','add')
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    title('�ز�Ƶ�ʱ仯��')
end


% ��ͼ
ax1 = f.Children(5); %���ͼʱ�ǵ���
ax2 = f.Children(4);
ax3 = f.Children(3);
ax4 = f.Children(2);
ax5 = f.Children(1);
t = obj.storage.dataIndex/obj.sampleFreq; %ʹ�ò���������ʱ��
% I/Qͼ
plot(ax1, obj.storage.I_Q(1001:end,1), obj.storage.I_Q(1001:end,4), 'LineStyle','none', 'Marker','.')
% I_Pͼ
plot(ax2, t, double(obj.storage.I_Q(:,1))) %����������������Ҫһ��
% �����
index = isnan(obj.storage.dataIndex) | obj.storage.bitFlag~=0; %��Ч���ݵ�����
plot(ax3, t(index), obj.storage.CN0(index), 'LineWidth',0.5)
% �ز�Ƶ��
plot(ax4, t, obj.storage.carrFreq, 'LineWidth',0.5)
% �ز�Ƶ�ʱ仯��
plot(ax5, t, obj.storage.carrAcc, 'LineWidth',0.5)

if nargout>0
    varargout{1} = f; %��ͼ������
end

end