function [res_rho, res_rhodot] = residual_cal(satmeas, satnav)
% ����в�
% satmeas:���ǲ���,[x,y,z,vx,vy,vz,rho,rhodot]
% satnav:���ǵ������,[x,y,z,vx,vy,vz,dtr,dtv]
% res_rho:α��в�,����������,������
% res_rhodot:α���ʲв�,����������,������

rs = satmeas(:,1:3);
vs = satmeas(:,4:6);
rho = satmeas(:,7); %������α��
rhodot = satmeas(:,8); %������α����

rp = satnav(1:3);
vp = satnav(4:6);
dtr = satnav(7);
dtv = satnav(8);

n = size(satmeas,1); %���Ǹ���
rps = rs - ones(n,1)*rp; %���ջ�ָ������λ��ʸ��
R = vecnorm(rps,2,2); %����ȡģ,���ջ������ǵ����۾���
rpsu = rps ./ (R*[1,1,1]); %���ջ�ָ���������ߵ�λʸ��
vps = vs - ones(n,1)*vp; %������Խ��ջ����ٶ�
V = sum(vps.*rpsu,2); %����ٶ�������ʸ����ͶӰ,���۾���仯��

c = 299792458;
res_rho = rho - R - dtr*c; %α��в�
res_rhodot = rhodot - V - dtv*c; %α���ʲв�

end