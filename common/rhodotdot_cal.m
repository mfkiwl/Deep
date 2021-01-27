function rhodotdot = rhodotdot_cal(rsvsas, rp, vp, geogInfo)
% ���������˶��������Լ��ٶ�(һ������)
% rsvsas:����ecefλ���ٶȼ��ٶ�,[x,y,z,vx,vy,vz,ax,ay,az]
% rp:���ջ�ecefλ��
% vp:���ջ�ecef�ٶ�
% geogInfo:������Ϣ

rs = rsvsas(1:3);
vs = rsvsas(4:6);
as = rsvsas(7:9);
ap = cross(geogInfo.wene,vp); %���ݸ��϶���,����ϵ��ת����ĸ��Ӽ��ٶ�
rps = rs - rp; %���ջ�ָ������λ��ʸ��
vps = vs - vp;
aps = as - ap;
R = norm(rps); %���ջ������ǵľ���
rhodotdot = (aps*rps'+vps*vps'-(vps*rps'/R)^2) / R;

end