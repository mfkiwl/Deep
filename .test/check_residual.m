%% �����ο�λ��,����α��α���ʲв�
% ���������鿴resR,resV����.
% Ӧ������ʱ�ӷ���ʱ����

sv = nCoV.storage.satmeas; %���ǲ�������
p0 = [45.73104, 126.62482, 200]; %�ο�λ��
rp = lla2ecef(p0);
satnav = [rp,[0,0,0],0,0];

svN = length(sv); %������
n = size(sv{1},1); %���ݵ���

resR = zeros(n,svN);
resV = zeros(n,svN);

satmeas = zeros(svN,8); %ÿ�ε����ǲ�������
for k=1:n
    for i=1:svN
        satmeas(i,:) = sv{i}(k,:);
    end
    [res_rho, res_rhodot] = residual_cal(satmeas, satnav);
    resR(k,:) = res_rho; %α��в�
    resV(k,:) = res_rhodot; %α���ʲв�
end