function varargout = plot_codeFreq(obj, varargin)
% ����Ƶ��

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
end

% ��ͼ
ax = f.Children(1);
t = obj.storage.dataIndex/obj.sampleFreq;
plot(ax, t, obj.storage.codeFreq)

if nargout>0
    varargout{1} = f; %��ͼ������
end

end