function [phi, phidot] = windup(as, bs, k, wb, Ceb)
% ������λ����ЧӦ�������λ����Ƶ�����,[��,Hz]
% as:���Ǳ���ϵ��x�ᵥλʸ��
% bs:���Ǳ���ϵ��y�ᵥλʸ��
% k:����ָ�����ߵ����ߵ�λʸ��
% wb:������ת���ٶ�,rad/s
% Ceb:ecefϵ�����߱���ϵ������任��

% ���ջ�����ż����
ar = [0,1,0]*Ceb; %����
br = [1,0,0]*Ceb; %����
Dr = ar - k*(k*ar') + cross(k,br);
Drm = norm(Dr);

% ��������ż����
Ds = as - k*(k*as') - cross(k,bs);
Dsm = norm(Ds);

% ������
zeta = k*cross(Ds,Dr)';

% cos(phi)
cos_phi = Ds*Dr' / (Dsm*Drm);

% phi
phi = sign(zeta) * acos(cos_phi);
phi = phi/2/pi; %��

% Drdot
ardot = cross(wb,[0,1,0])*Ceb;
brdot = cross(wb,[1,0,0])*Ceb;
Drdot = ardot - k*(k*ardot') + cross(k,brdot);

% phidot
phidot = sign(zeta) * -1/sqrt(1-cos_phi^2) * (Ds/Dsm) * (Drdot/Drm-(Dr*Drdot')*Dr/Drm^3)';
% phidot = sign(zeta) * -1/sqrt(1-cos_phi^2) * (Ds/Dsm) * (cross(Dr,cross(Drdot,Dr))/Drm^3)';
phidot = phidot/2/pi; %Hz

end