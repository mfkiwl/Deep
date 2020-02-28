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
azi = mod(obj.aziele(index,2),360)/180*pi; %��λ��ת�ɻ���,0~360��
ele = obj.aziele(index,3); %�߶Ƚ�,deg

% ͳ�Ƹ��ٵ�������
svTrack = obj.svList([obj.channels.ns]~=0);

% ����figure
f = figure('Name','Constellation');
c = uicontextmenu; %����Ŀ¼
f.UIContextMenu = c; %Ŀ¼�ӵ�figure��,��figure�հ״��Ҽ�����

% ����figureĿ¼��(*)
uimenu(c, 'MenuSelectedFcn',@figureCallback, 'Text','Print log');
uimenu(c, 'MenuSelectedFcn',@figureCallback, 'Text','Plot trackResult');

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
    ch = find(obj.svList==PRN(k)); %�ÿ����ǵ�ͨ����
    % ����Ŀ¼��(*)
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','trackResult');
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','I_Q');
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','I_P');
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','I_P(flag)');
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','carrFreq');
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','codeFreq');
    uimenu(c, 'MenuSelectedFcn',@scatterCallback, 'UserData',ch, 'Text','carrAcc');
end
            
    %% ��figure���Ҽ��Ļص�����
    function figureCallback(source, ~)
        switch source.Text
            case 'Print log'
                obj.print_all_log;
            case 'Plot trackResult'
                obj.plot_all_trackResult;
        end
    end
            
    %% ���������Ҽ��Ļص�����
    function scatterCallback(source, ~)
        % ����Ҫ�������������(source, callbackdata),���ֲ���Ҫ
        % ��һ������matlab.ui.container.Menu����
        % �ڶ�������ui.eventdata.ActionData
        kc = source.UserData; %ͨ����
        switch source.Text
            case 'trackResult'
                plot_trackResult(obj.channels(kc))
            case 'I_Q'
                plot_I_Q(obj.channels(kc))
            case 'I_P'
                plot_I_P(obj.channels(kc))
            case 'I_P(flag)'
                plot_I_P_flag(obj.channels(kc))
            case 'carrFreq'
                plot_carrFreq(obj.channels(kc))
            case 'codeFreq'
                plot_codeFreq(obj.channels(kc))
            case 'carrAcc'
                plot_carrAcc(obj.channels(kc))
        end
    end

end