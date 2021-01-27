function interact_constellation(obj)
% ����������ͼ

% ����figure
f = figure('Name','Constellation');
c = uicontextmenu; %����Ŀ¼
f.UIContextMenu = c; %Ŀ¼�ӵ�figure��,��figure�հ״��Ҽ�����

% ����figureĿ¼��(*)
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'print_all_log'}, 'Text','Print all log');
% uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_all_trackResult'}, 'Text','Plot all trackResult');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_all_I_Q'}, 'Text','Print all I/Q');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_all_I_P'}, 'Text','Print all I_P');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_all_carrNco'}, 'Text','Print all carrNco');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_all_carrAcc'}, 'Text','Print all carrAcc');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_sv_3d'}, 'Text','Plot 3D', 'Separator','on');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_svnum'}, 'Text','Plot svnum');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_motionState'}, 'Text','Plot motionState');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_df'}, 'Text','Plot df', 'Separator','on');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_pos'}, 'Text','Plot pos', 'Separator','on');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_vel'}, 'Text','Plot vel');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_att'}, 'Text','Plot att');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_bias_gyro'}, 'Text','Plot bias_gyro');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'plot_bias_acc'}, 'Text','Plot bias_acc');
uimenu(c, 'MenuSelectedFcn',{@menuCallback,obj,'kml_output'}, 'Text','KML output', 'Separator','on');

% ������������
ax = polaraxes; %������������
ax.NextPlot = 'add'; %hold on
ax.RLim = [0,90]; %�߶ȽǷ�Χ
ax.RDir = 'reverse'; %�߶Ƚ�������90��
% ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
ax.ThetaZeroLocation = 'top'; %��λ��0����

% ����һ��������,�ı�߶Ƚ���ʾ��Χ
sl = uicontrol;
sl.Style = 'slider';
sl.Position = [15,15,120,15];
sl.Max = 80;
sl.Min = 0;
sl.SliderStep = [2,8]/80;
sl.Callback = @changeEleRange;
    function changeEleRange(src, ~)
        ax.RLim = [floor(src.Value),90];
    end

%% GPS����
if obj.GPSflag==1
    % ���û�����鲻��ͼ
    if isempty(obj.GPS.almanac)
        disp('GPS almanac doesn''t exist!')
        return
    end
    
    % ��ѡ�߶ȽǴ���0������
    index = obj.GPS.aziele(:,3)>0; %�߶ȽǴ���0����������
    PRN = obj.GPS.aziele(index,1);
    azi = obj.GPS.aziele(index,2)/180*pi; %��λ��ת�ɻ���
    ele = obj.GPS.aziele(index,3); %�߶Ƚ�,deg
    
    % ͳ�Ƹ��ٵ�������
    svTrack = obj.GPS.svList([obj.GPS.channels.ns]~=0);
    
    % ��ͼ
    for k=1:length(PRN) %�������и߶ȽǴ���0������
        % �͸߶Ƚ�����,͸��
        if ele(k)<obj.GPS.eleMask
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
        % ���ٵ�������,�߿�Ӵ�,�����Ҽ��˵�
        polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'LineWidth',2)
        t = text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                'VerticalAlignment','middle');
        c = uicontextmenu; %����Ŀ¼
        t.UIContextMenu = c; %Ŀ¼�ӵ�text��,��Ϊ���ָ�����ԲȦ
        objch = obj.GPS.channels(obj.GPS.svList==PRN(k)); %ͨ������
        % ����Ŀ¼��(*)
        uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_trackResult'}, 'Text','trackResult');
        uimenu(c, 'MenuSelectedFcn',{@menuCallback,objch,'plot_I_Q'}, 'Text','I/Q', 'Separator','on');
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
end

%% BDS����
if obj.BDSflag==1
    % ���û�����鲻��ͼ
    if isempty(obj.BDS.almanac)
        disp('BDS almanac doesn''t exist!')
        return
    end
    
    % ��ѡ�߶ȽǴ���0������
    index = obj.BDS.aziele(:,3)>0; %�߶ȽǴ���0����������
    PRN = obj.BDS.aziele(index,1);
    azi = obj.BDS.aziele(index,2)/180*pi; %��λ��ת�ɻ���
    ele = obj.BDS.aziele(index,3); %�߶Ƚ�,deg
    
    % ͳ�Ƹ��ٵ�������
    svTrack = obj.BDS.svList([obj.BDS.channels.ns]~=0);
    
    % ��ͼ
    for k=1:length(PRN) %�������и߶ȽǴ���0������
        % �͸߶Ƚ�����,͸��
        if ele(k)<obj.BDS.eleMask
            polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[255,65,65]/255, ...
                         'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.5)
            text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                'VerticalAlignment','middle');
            continue
        end
        % û���ٵ�����,�߿�����
        if ~ismember(PRN(k),svTrack)
            polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[255,65,65]/255, ...
                         'MarkerEdgeColor',[127,127,127]/255)
            text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                'VerticalAlignment','middle');
            continue
        end
        % ���ٵ�������,�߿�Ӵ�,�����Ҽ��˵�
        polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[255,65,65]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'LineWidth',2)
        t = text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                'VerticalAlignment','middle');
        c = uicontextmenu; %����Ŀ¼
        t.UIContextMenu = c; %Ŀ¼�ӵ�text��,��Ϊ���ָ�����ԲȦ
        objch = obj.BDS.channels(obj.BDS.svList==PRN(k)); %ͨ������
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