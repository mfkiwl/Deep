function figureMargin(ax, h, scale)
% figure��������������
% ax:�����
% h:���߶���
% scale:���ױ���

y1 = min(h.YData);
y2 = max(h.YData);
if y2>y1 %���߲��ǳ�ֵ
    ym = (y1+y2)/2; %��ֵ
    yh = (y2-y1)/2; %���߷�Χ��һ��
    set(ax, 'ylim', [ym-yh*(1+scale),ym+yh*(1+scale)])
end

end