function [azi, ele] = cal_aziele(obj)
% ���������ǲ��������Ƿ�λ�Ǹ߶Ƚ�
% azi,ele:ÿ��һ������

if isempty(obj.result.satmeasIndex) %���û������,ֱ�ӷ���
    return
end

n = size(obj.storage.pos,1); %���ݵ���
svN = obj.chN; %������

azi = zeros(svN,n); %ÿ��һ������
ele = zeros(svN,n);
rs = zeros(svN,3); %��ÿ�����ǵ�λ��

% �����������Ƿ�λ�Ǹ߶Ƚ�
for k=1:n
    for i=1:svN
        rs(i,:) = obj.storage.satmeas{i}(k,1:3);
    end
    [azi(:,k), ele(:,k)] = aziele_xyz(rs, obj.storage.pos(k,:));
end
azi = azi'; %ת����ÿ��һ������
ele = ele';

% ɾ�������ݵ���
azi = azi(:,obj.result.satmeasIndex);
ele = ele(:,obj.result.satmeasIndex);

% ��ͼ
labels = obj.result.satmeasPRN; %���Ǳ���ַ���
if nargout==0
    figure('Name','aziele')
    subplot(2,1,1) %����λ��
    plot(azi, 'LineWidth',1.5)
    set(gca, 'YLim',[0,360])
    legend(labels)
    grid on
    title('azimuth')
    subplot(2,1,2) %���߶Ƚ�
    plot(ele, 'LineWidth',1.5)
    set(gca, 'YLim',[5,90])
    legend(labels)
    grid on
    title('elevation')
end

end