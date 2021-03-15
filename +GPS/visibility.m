function visibility(filepath, c, zone, p, h)
% ������ͼ�ϻ�һ��ʱ������ǹ켣,2����һ����
% filepath:����洢��·��,��β����\
% c:[year, mon, day, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% p:γ����,deg
% h:����ʱ��,Сʱ

% ��ȡ����
t = UTC2GPS(c, zone); %[week,second]
filename = GPS.almanac.download(filepath, t); %��ȡ����
almanac = GPS.almanac.read(filename); %�������ļ�

% ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
svN = size(almanac,1); %������
n = h*30; %����
azi = zeros(svN,n); %ÿһ��Ϊһ��ʱ���
ele = zeros(svN,n);
ts = t(2); %��������
for k=1:n
    rs = rs_almanac(almanac(:,5:end), t);
    [azi(:,k), ele(:,k)] = aziele_xyz(rs, p);
    ts = ts+120; %����ʱ��
end

% ��ȡ�߶ȽǴ���0������
index = zeros(1,svN, 'logical'); %�ɼ���������
for k=1:svN
    if sum(ele(k,:)>0)~=0 %���ڸ߶ȽǴ���0��ʱ���
        index(k) = 1;
    end
end
PRN = almanac(index,1);
azi = azi(index,:)/180*pi; %��λ��ת�ɻ���
ele = ele(index,:);

% ����������
figure
ax = polaraxes; %������������
ax.NextPlot = 'add'; %hold on
ax.RLim = [0,90]; %�߶ȽǷ�Χ
ax.RDir = 'reverse'; %�߶Ƚ�������90��
ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
ax.ThetaZeroLocation = 'top'; %��λ��0����

% ��ͼ�켣��
for k=1:length(PRN)
    polarplot(azi(k,:),ele(k,:), 'Color',[0,0.447,0.741], 'LineWidth',1)
end

% ���˵�
for k=1:length(PRN)
    if ele(k,1)>0 %���߶ȽǴ���0,�����,��ɫ��
        polarscatter(azi(k,1),ele(k,1), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.8)
        text(azi(k,1),ele(k,1),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                'VerticalAlignment','middle')
        continue %����յ�ֻ��һ��
    end
    if ele(k,end)>0 %�յ�߶ȽǴ���0,���յ�,��ɫǳ
        polarscatter(azi(k,end),ele(k,end), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.3)
        text(azi(k,end),ele(k,end),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                    'VerticalAlignment','middle')
    end
end

end