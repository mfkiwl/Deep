% �����ο�λ��,����α��α���ʲв�
% ���������鿴resR,resV����

sv = nCoV.storage.satmeas; %���ǲ�������
% p0 = [45.73104, 126.62482, 200]; %�ο�λ��
% p0 = [45.74565, 126.62615, 180];
p0 = [45.7443, 126.62595, 170];
rp = lla2ecef(p0);
satnav = [rp,[0,0,0],0,0];

chN = length(sv); %������
n = size(sv{1},1); %����

resR = zeros(n,chN);
resV = zeros(n,chN);

satmeas = zeros(chN,8); %ÿ�ε����ǲ�������
for k=1:n
    for i=1:chN
        satmeas(i,:) = sv{i}(k,:);
    end
    [res_rho, res_rhodot] = residual_cal(satmeas, satnav);
    resR(k,:) = res_rho; %α��в�
    resV(k,:) = res_rhodot; %α���ʲв�
end