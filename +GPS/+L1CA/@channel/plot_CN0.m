function varargout = plot_CN0(obj, varargin)
% �������

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
    f = figure('Name',name_str);
    axes('Box','on', 'NextPlot','add')
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    set(gca, 'YLim',[0,60])
end

% ��ͼ
ax = f.Children(1);
index = isnan(obj.storage.dataIndex) | obj.storage.bitFlag~=0; %��Ч���ݵ�����
t = obj.storage.dataIndex/obj.sampleFreq;
plot(ax, t(index), obj.storage.CN0(index))

if nargout>0
    varargout{1} = f; %��ͼ������
end

end