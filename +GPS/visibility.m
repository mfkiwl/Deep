function visibility(filepath, c, zone, p, h)
% ������ͼ�ϻ�һ��ʱ������ǹ켣,2����һ����
% filepath:����洢��·��,��β����\
% c:[year, mon, date, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% p:γ����,deg
% h:����ʱ��,Сʱ

% ��ȡ����
t = utc2gps(c, zone); %[week,second]
filename = GPS.almanac.download(filepath, t); %��ȡ����
almanac = GPS.almanac.read(filename); %�������ļ�

% ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
n = size(almanac,1); %������
m = h*30; %����
aziele = zeros(n,2,m); %[azi,ele],����άΪʱ��
for k=1:m
    aziele(:,:,k) = aziele_almanac(almanac(:,3:end), t, p); %[azi,ele]
    t(2) = t(2)+120; %����ʱ��
    if t(2)>=604800
        t(1) = t(1)+1;
        t(2) = t(2)-604800;
    end
end

% ��ȡ�߶ȽǴ���0������
index = zeros(1,n, 'logical'); %�ɼ���������
for k=1:n
    if ~isempty(find(aziele(k,2,:)>0,1)) %���ڸ߶ȽǴ���0
        index(k) = 1;
    end
end
PRN = almanac(index,1);
azi = mod(aziele(index,1,:),360)/180*pi; %��λ��ת�ɻ���,0~360��
azi = reshape(azi,length(PRN),m); %��Ϊ����,��Ϊʱ��
ele = aziele(index,2,:);
ele = reshape(ele,length(PRN),m);

% ����������
figure
ax = polaraxes; %������������
hold(ax, 'on')
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