function ax = sv_3Dview(aziele, sys, ax)
% ����ά���껭����λ��,���Խ���ͼ����,��ԭͼ�ϵ���
% aziele:���Ƿ�λ�Ǹ߶Ƚ�,[PRN,azi,ele],deg
% sys:����ϵͳ����
% ax:��ά������

PRN = aziele(:,1);
azi = aziele(:,2);
ele = aziele(:,3);

% ����ֱ������
n = length(PRN); %���Ǹ���
p = zeros(n,3);
p(:,1) = cosd(ele).*cosd(90-azi); %��λ����˳ʱ��Ϊ��,ֱ����������ʱ��Ϊ��
p(:,2) = cosd(ele).*sind(90-azi);
p(:,3) = sind(ele);

% ������ƽ��
if ~exist('ax','var')
    figure
    ax = axes; %ֱ��������
    X = [-1,1;-1,1];
    Y = [1,1;-1,-1];
    Z = [0,0;0,0];
    surf(X,Y,Z, 'EdgeColor',[0.929,0.694,0.125], 'FaceColor',[0.929,0.694,0.125], 'FaceAlpha',0.4) %����ƽ��
    axis equal
    set(gca, 'Zlim',[-0.2,1.2])
    hold on
    text(0,1,0,'N')
    text(1,0,0,'E')
    plot3([-1,1],[0,0],[0,0], 'Color',[0.929,0.694,0.125]) %����ƽ��ָ���
    plot3([0,0],[-1,1],[0,0], 'Color',[0.929,0.694,0.125])
    plot3(0,0,0, 'Color',[0.929,0.694,0.125], 'LineStyle','none', 'Marker','.', 'MarkerSize',25) %��ԭ��
    rotate3d on %ֱ�Ӵ�3D��ͼ��ת,�Ҽ�ѡ���ӽ�,˫���ָ�
end

% ������ɫ
switch sys
    case 'G'
        color = [76,114,176]/255;
    case 'C'
        color = [196,78,82]/255;
    otherwise
        color = [0,0,0]/255;
end

% ������
for k=1:n
    plot3(p(k,1),p(k,2),p(k,3), 'Color',color, 'LineStyle','none', 'Marker','.', 'MarkerSize',25) %���ǵ�
    plot3([0,p(k,1)],[0,p(k,2)],[0,p(k,3)], 'Color',color, 'LineWidth',0.5) %���ǵ���ԭ�������
    text(p(k,1),p(k,2),p(k,3),['  ',sys,num2str(PRN(k))]) %���Ǳ��
end

end