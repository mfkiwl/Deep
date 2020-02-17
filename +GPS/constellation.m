function constellation(filepath, c, zone, p, ax)
% ��ָ��ʱ���GPS����ͼ,���Խ���ͼ����,������ϵͳ����ͼ�ϵ���
% filepath:����洢��·��,��β����\
% c:[year, mon, date, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% p:γ����,deg
% ax:��������

% ��ȡ����
t = utc2gps(c, zone); %[week,second]
filename = GPS.almanac.download(filepath, t); %��ȡ����
almanac = GPS.almanac.read(filename); %�������ļ�

% ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
aziele = aziele_almanac(almanac(:,3:end), t, p); %[azi,ele]

% ��ȡ�߶ȽǴ���0������
index = find(aziele(:,2)>0); %�߶ȽǴ���0���к�
PRN = almanac(index,1);
azi = mod(aziele(index,1),360)/180*pi; %��λ��ת�ɻ���,0~360��
ele = aziele(index,2);

% ����������
if ~exist('ax','var')
    figure
    ax = polaraxes; %������������
    hold(ax, 'on')
    ax.RLim = [0,90]; %�߶ȽǷ�Χ
    ax.RDir = 'reverse'; %�߶Ƚ�������90��
    ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
    ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
    ax.ThetaZeroLocation = 'top'; %��λ��0����
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
title(sprintf('%d-%02d-%02d %02d:%02d:%02d', c))

end