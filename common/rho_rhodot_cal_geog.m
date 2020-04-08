function [rho, rhodot, rspu, Cen] = rho_rhodot_cal_geog(rs, vs, pos, vel)
% ʹ�ý��ջ���γ���ߵ���ϵ�ٶȼ���������Ծ�������ٶ�(�������)
% rs:����ecefλ��
% vs:����ecef�ٶ�
% pos:���ջ�γ����,deg
% vel:���ջ�����ϵ�ٶ�,������
% rho:������Ծ���
% rhodot:��������ٶ�
% rspu:ecefϵ������ָ����ջ��ĵ�λʸ��
% Cen:ecef������ϵ������任��

n = size(rs,1); %���Ǹ���

% ������Ծ���
rp = lla2ecef(pos);
rsp = ones(n,1)*rp - rs; %����ָ����ջ�
rho = vecnorm(rsp,2,2);
rspu = rsp ./ (rho*[1,1,1]);

% ��������ٶ�
Cen = dcmecef2ned(pos(1),pos(2));
vp = vel*Cen;
vsp = ones(n,1)*vp - vs; %���ջ�������ǵ��ٶ�
rhodot = sum(vsp.*rspu,2);

end