function ax = constellation(filepath, c, zone, p, ax)
% ��ָ��ʱ���GPS����ͼ,���Խ���ͼ����,������ϵͳ����ͼ�ϵ���
% filepath:����洢��·��,��β����\
% c:[year, mon, day, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% p:γ����,deg
% ax:��������

% ��ȡ����
t = UTC2GPS(c, zone); %[week,second]
filename = GPS.almanac.download(filepath, t); %��ȡ����
almanac = GPS.almanac.read(filename); %�������ļ�

% ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
aziele = aziele_almanac(almanac(:,6:end), t(2), p); %[azi,ele]

% ��ȡ�߶ȽǴ���0������
index = find(aziele(:,2)>0); %�߶ȽǴ���0���к�
PRN = almanac(index,1);
azi = mod(aziele(index,1),360)/180*pi; %��λ��ת�ɻ���,0~360��
ele = aziele(index,2);

% ����������
if ~exist('ax','var')
    figure
    ax = polaraxes; %������������
    ax.NextPlot = 'add'; %hold on
    ax.Clipping = 'off'; %�رռ��й���,�������Ƴ�������ʱ������ʾ
    ax.RLim = [0,90]; %�߶ȽǷ�Χ
    ax.RDir = 'reverse'; %�߶Ƚ�������90��
%     ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
    ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
    ax.ThetaZeroLocation = 'top'; %��λ��0����
    title(sprintf('%d-%02d-%02d %02d:%02d:%02d UTC%+d', c, zone))
    % ����һ��������,�ı�߶Ƚ���ʾ��Χ
    sl = uicontrol;
    sl.Style = 'slider';
    sl.Position = [15,15,120,15];
    sl.Max = 80;
    sl.Min = 0;
    sl.SliderStep = [2,8]/80;
    sl.Callback = @changeEleRange;
end
    function changeEleRange(src, ~)
        ax.RLim = [floor(src.Value),90];
    end

% ��ͼ
for k=1:length(PRN)
    if ele(k)<10 %�͸߶Ƚ�����,͸��
        polarscatter(ax, azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.5)
        text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle')
    else
        polarscatter(ax, azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255)
        text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle')
    end
end

end