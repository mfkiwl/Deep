function position = screenBlock(x, y, fx, fy)
% ��ȡ��Ļ���λ��
% position:[dx,dy,x,y],��λ:����
% x,y:���,����
% fx,fy:������µ׽ǵı���

screenSize = get(0,'ScreenSize'); %��ȡ��Ļ�ߴ�
dx = floor((screenSize(3)-x)*fx);
dy = floor((screenSize(4)-y)*fy);
position = [dx,dy,x,y];

end