function plot_sv_3d(obj)
% ����άֱ�����껭���ٵ�������

if obj.GPSflag==1
    % ��ȡ��λ�Ǹ߶Ƚ�
    index = obj.result.GPS.trackedIndex; %���ٵ�������ͨ������
    n = length(index); %���ٵ������Ǹ���
    aziele = zeros(n,3); %[PRN,azi,ele],deg
    for k=1:n
        PRN = obj.GPS.channels(index(k)).PRN; %���Ǳ��
        aziele(k,:) = obj.GPS.aziele(obj.GPS.aziele(:,1)==PRN,:);
    end
    % ��ͼ
    ax = sv_3Dview(aziele, 'G');
end

if obj.BDSflag==1
    % ��ȡ��λ�Ǹ߶Ƚ�
    index = obj.result.BDS.trackedIndex; %���ٵ�������ͨ������
    n = length(index); %���ٵ������Ǹ���
    aziele = zeros(n,3); %[PRN,azi,ele],deg
    for k=1:n
        PRN = obj.BDS.channels(index(k)).PRN; %���Ǳ��
        aziele(k,:) = obj.BDS.aziele(obj.BDS.aziele(:,1)==PRN,:);
    end
    % ��ͼ
    if exist('ax','var')
        sv_3Dview(aziele, 'C', ax);
    else
        sv_3Dview(aziele, 'C');
    end
end

end