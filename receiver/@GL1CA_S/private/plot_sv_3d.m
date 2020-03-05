function plot_sv_3d(obj)
% ����άֱ�����껭���ٵ�������
% obj:���ջ�����

% ��ȡ��λ�Ǹ߶Ƚ�
index = obj.result.trackedIndex; %���ٵ�������ͨ������
n = length(index); %���ٵ������Ǹ���
aziele = zeros(n,3); %[PRN,azi,ele],deg
for k=1:n
    PRN = obj.channels(index(k)).PRN; %���Ǳ��
    aziele(k,:) = obj.aziele(obj.aziele(:,1)==PRN,:);
end

% ��ͼ
sv_3Dview(aziele, 'G');

end