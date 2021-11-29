function varargout = plot_I_Q(obj, varargin)
% ��I/Qͼ,�����½�ͼ��,Ҳ�����ڱ��ͼ�ϵ���
% ���������������ʱ,�½�figure
% ���������Ϊ�ַ���ʱ,�½�figure,����ͼ������������ַ���
% ���������Ϊfigure���ʱ,������figure�ϻ�

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
    axis equal
end

% ��ͼ
ax = f.Children(1);
plot(ax, obj.storage.I_Q(1001:end,1), obj.storage.I_Q(1001:end,4), 'LineStyle','none', 'Marker','.')

if nargout>0
    varargout{1} = f; %��ͼ������
end

end