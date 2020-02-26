function satnav = satnavSolve(sv, rp0)
% ���ǵ�������,���������С��4,����NaN
% vs:���ǲ�����Ϣ,[x,y,z,vx,vy,vz,rho,rhodot]
% rp0:���ջ�����λ��,ecef
% satnav:���ǵ������,[lat,lon,h, rpx,rpy,rpz, vn,ve,vd, dtr,dtv]

satnav = NaN(1,11);

% ��������С��4,ֱ�ӷ���
if size(sv,1)<4
    return
end

c = 299792458; %����
rs = sv(:,1:3); %��������λ��
vs = sv(:,4:6); %���������ٶ�
R = sv(:,7); %rho,m
V = sv(:,8); %rhodot,m/s
n = size(sv,1); %���Ǹ���
G = zeros(n,4); %����ʸ������
G(:,4) = -1; %���һ��Ϊ-1

% ������ջ�λ��
x0 = [rp0, 0]'; %��ֵ
cnt = 0; %��������
while 1
    E = rs - ones(n,1)*x0(1:3)'; %���ջ�ָ������λ��ʸ��
    Em = sum(E.*E, 2).^0.5; %ȡ���е�ģ
    Eu = E ./ (Em*[1,1,1]); %���ջ�ָ���������ߵ�λʸ��
    G(:,1:3) = Eu;
    S = sum(Eu.*rs, 2); %����λ��ʸ��������ʸ����ͶӰ
    x = (G'*G)\G'*(S-R); %��С����
    if norm(x-x0)<1e-3 %��������
        break
    end
    cnt = cnt+1;
    if cnt==10 %������10��
        break
    end
    x0 = x;
end
rp = x(1:3)';
satnav(1:3) = ecef2lla(rp); %γ����
satnav(4:6) = rp; %ecefλ��
satnav(10) = x(4)/c; %���ջ��Ӳ�,s

% ������ջ��ٶ�
 E = rs - ones(n,1)*rp;
 Em = sum(E.*E, 2).^0.5;
 Eu = E ./ (Em*[1,1,1]);
 G(:,1:3) = Eu;
 S = sum(Eu.*vs, 2);
 v = (G'*G)\G'*(S-V);
 Cen = dcmecef2ned(satnav(1), satnav(2));
 satnav(7:9) = Cen*v(1:3); %����ϵ���ٶ�
 satnav(11) = v(4)/c; %���ջ���Ƶ��,������

end