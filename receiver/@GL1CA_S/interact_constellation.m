function interact_constellation(obj)
% ����������ͼ

% ���û�����鲻��ͼ
if isempty(obj.almanac)
    disp('Almanac doesn''t exist!')
    return
end

% ��ѡ�߶ȽǴ���0������
index = find(obj.aziele(:,3)>0); %�߶ȽǴ���0����������
PRN = obj.aziele(index,1);
azi = obj.aziele(index,2)/180*pi; %��λ��ת�ɻ���
ele = obj.aziele(index,3); %�߶Ƚ�,deg

% ͳ�Ƹ��ٵ�������
svTrack = obj.svList([obj.channels.ns]~=0);

% ����figure
f = figure('Name','Constellation');
c = uicontextmenu; %����Ŀ¼
f.UIContextMenu = c; %Ŀ¼�ӵ�figure��,��figure�հ״��Ҽ�����

% ����figureĿ¼��(*)
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'print_all_log'}, 'Text','Print log');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_all_trackResult'}, 'Text','Plot trackResult');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_sv_3d'}, 'Text','Plot 3D');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'cal_aziele'}, 'Text','Cal aziele', 'Separator','on');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'cal_iono'}, 'Text','Cal iono');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_df'}, 'Text','Plot df', 'Separator','on');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_pos'}, 'Text','Plot pos', 'Separator','on');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_vel'}, 'Text','Plot vel');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_att'}, 'Text','Plot att');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_bias_gyro'}, 'Text','Plot bias_gyro');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_bias_acc'}, 'Text','Plot bias_acc');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'kml_output'}, 'Text','KML output', 'Separator','on');

% ������������
ax = polaraxes; %������������
ax.NextPlot = 'add';
ax.RLim = [0,90]; %�߶ȽǷ�Χ
ax.RDir = 'reverse'; %�߶Ƚ�������90��
ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
ax.ThetaZeroLocation = 'top'; %��λ��0����

% ��ͼ
for k=1:length(PRN) %�������и߶ȽǴ���0������
    % �͸߶Ƚ�����,͸��
    if ele(k)<obj.eleMask
        polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.5)
        text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle');
        continue
    end
    % û���ٵ�����,�߿�����
    if ~ismember(PRN(k),svTrack)
        polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255)
        text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle');
        continue
    end
    % ���ٵ�������,�߿�Ӵ�,�����Ҽ��˵�,�μ�uicontextmenu help
    polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                 'MarkerEdgeColor',[127,127,127]/255, 'LineWidth',2)
    t = text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle');
    c = uicontextmenu; %����Ŀ¼
    t.UIContextMenu = c; %Ŀ¼�ӵ�text��,��Ϊ���ָ�����ԲȦ
    objch = obj.channels(obj.svList==PRN(k)); %ͨ������
    % ����Ŀ¼��(*)
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_trackResult'}, 'Text','trackResult');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_I_Q'}, 'Text','I_Q', 'Separator','on');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_I_P'}, 'Text','I_P');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_I_P_flag'}, 'Text','I_P(flag)');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_codeFreq'}, 'Text','codeFreq', 'Separator','on');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_carrFreq'}, 'Text','carrFreq', 'Separator','on');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_carrNco'}, 'Text','carrNco');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_carrAcc'}, 'Text','carrAcc');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_codeDisc'}, 'Text','codeDisc', 'Separator','on');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_carrDisc'}, 'Text','carrDisc');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_freqDisc'}, 'Text','freqDisc');
    uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_quality'}, 'Text','quality', 'Separator','on');
end

    %% �Ҽ��˵��Ļص�����
    function menuCallback(varargin)
        % ʹ�ÿɱ��������,ͷ���������ǹ̶���
        % ��һ������Ϊmatlab.ui.container.Menu����
        % �ڶ�������Ϊui.eventdata.ActionData
        % ����������Ϊ�����
        % ���ĸ�����Ϊ��Ҫ���õ����Ա�����ַ���(��������)
        eval(['varargin{3}.',varargin{4},';'])
    end

end