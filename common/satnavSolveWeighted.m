function satnav = satnavSolveWeighted(sv, rp0)
% ���ǵ�������,���������С��4,����NaN
% vs:���ǲ�����Ϣ,[x,y,z,vx,vy,vz,rho,rhodot,R_rho,R_rhodot]
% rp0:���ջ�����λ��,ecef
% satnav:���ǵ������,[lat,lon,h,x,y,z,vn,ve,vd,vx,vy,vz,dtr,dtv]

satnav = NaN(1,14);

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

% ���鼸�ξ�������
E = rs - ones(n,1)*rp0;
Em = vecnorm(E,2,2);
Eu = E ./ (Em*[1,1,1]);
G(:,1:3) = Eu;
D = inv(G'*G);
Ddiag = diag(D);
PDOP = sqrt(Ddiag(1)+Ddiag(2)+Ddiag(3));
if PDOP>10 %���ξ������Ӵ�Ͳ�����
    return
end

% Ȩֵ����
Wr = diag(sv(:,9).^-1); %λ��Ȩֵ
Wv = diag(sv(:,10).^-1); %�ٶ�Ȩֵ

% ������ջ�λ��
x0 = [rp0, 0]'; %��ֵ
cnt = 0; %��������
while 1
    E = rs - ones(n,1)*x0(1:3)'; %���ջ�ָ������λ��ʸ��
    Em = vecnorm(E,2,2); %ȡ���е�ģ
    Eu = E ./ (Em*[1,1,1]); %���ջ�ָ���������ߵ�λʸ��
    G(:,1:3) = Eu;
    S = sum(Eu.*rs,2); %����λ��ʸ��������ʸ����ͶӰ
    x = (G'*Wr*G)\G'*Wr*(S-R); %��С����
    if norm(x-x0)<1e-3 %��������
        break
    end
    cnt = cnt+1;
    if cnt==10 %������10��
        break
    end
    x0 = x;
end
rp = x(1:3)'; %������
satnav(1:3) = ecef2lla(rp); %γ����
satnav(4:6) = rp; %ecefλ��
satnav(13) = x(4)/c; %���ջ��Ӳ�,s

% ������ջ��ٶ�
E = rs - ones(n,1)*rp;
Em = vecnorm(E,2,2);
Eu = E ./ (Em*[1,1,1]);
G(:,1:3) = Eu;
S = sum(Eu.*vs,2);
cm = 1 + S/c; %��������
G(:,4) = -cm;
v = (G'*Wv*G)\G'*Wv*(S-V.*cm);
% v = (G'*Wv*G)\G'*Wv*(S-V);
Cen = dcmecef2ned(satnav(1), satnav(2));
satnav(7:9) = Cen*v(1:3); %����ϵ���ٶ�
satnav(10:12) = v(1:3); %ecefϵ���ٶ�
satnav(14) = v(4)/c; %���ջ���Ƶ��,������

end