function [azi, ele] = aziele_xyz(rs, lla)
% ʹ������ecefλ�ü������Ƿ�λ�Ǹ߶Ƚ�
% rs:����ecefλ��,ÿ��Ϊ1������
% lla:���ջ�λ��,deg
% azi,ele:���Ƿ�λ�Ǹ߶Ƚ�,deg,������

Cen = dcmecef2ned(lla(1),lla(2));
rp = lla2ecef(lla); %���ջ�ecefλ��
rps = rs - rp; %���ջ�ָ������λ��ʸ��
rho = vecnorm(rps,2,2); %���ÿ�����ǵľ���
rpsu = rps ./ (rho*[1,1,1]); %���ջ�ָ�����ǵ����ߵ�λʸ��
rpsu_n = rpsu*Cen'; %����ʸ��ת������ϵ��
azi = atan2d(rpsu_n(:,2),rpsu_n(:,1));
azi = mod(azi,360); %0~360��
ele = asind(-rpsu_n(:,3));

end