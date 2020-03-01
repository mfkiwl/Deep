function rhodotdot = rhodotdot_cal(rsvsas, rp)
% ���������˶������α���ʱ仯��
% rsvsas:����ecefλ���ٶȼ��ٶ�,[x,y,z,vx,vy,vz,ax,ay,az]
% rp:���ջ�ecefλ��

rs = rsvsas(1:3);
vs = rsvsas(4:6);
as = rsvsas(7:9);
rps = rs - rp; %���ջ�ָ������λ��ʸ��
R = norm(rps); %���ջ������ǵľ���
rhodotdot = (as*rps'+vs*vs'-(vs*rps'/R)^2) / R;

end