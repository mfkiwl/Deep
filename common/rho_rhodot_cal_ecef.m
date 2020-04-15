function [rho, rhodot, rspu] = rho_rhodot_cal_ecef(rs, vs, rp, vp)
% ʹ�ý��ջ���ecefλ���ٶȼ���������Ծ�������ٶ�(�������)

n = size(rs,1); %���Ǹ���

% ������Ծ���
rsp = ones(n,1)*rp - rs; %����ָ����ջ�
rho = vecnorm(rsp,2,2);
rspu = rsp ./ (rho*[1,1,1]);

% ��������ٶ�
vsp = ones(n,1)*vp - vs; %���ջ�������ǵ��ٶ�
rhodot = sum(vsp.*rspu,2);

end