%% �������ǵ����˲���(ʹ������)

%% ���ò���
para.dt = nCoV.dtpos / 1000;
para.p0 = nCoV.storage.pos(1,1:3);
para.v0 = [0,0,0];
para.P0_pos = 5; %m
para.P0_vel = 1; %m/s
para.P0_acc = 1; %m/s^2
para.P0_dtr = 2e-8; %s
para.P0_dtv = 3e-9; %s/s
para.Q_pos = 0;
para.Q_vel = 0;
para.Q_acc = 100;
para.Q_dtr = 0;
para.Q_dtv = 1e-9;
NF = filter_sat(para);

svN = nCoV.chN;
sv = zeros(svN,10);
n = size(nCoV.storage.ta,1);

%% ������
output.satnav = zeros(n,14);
output.pos = zeros(n,3);
output.vel = zeros(n,3);
output.clk = zeros(n,2);
output.P = zeros(n,11);

%% ����
for k=1:n
    % ��������
    for m=1:svN
        sv(m,:) = nCoV.storage.satmeas{m}(k,:);
    end
    indexP = (nCoV.storage.svsel(k,:)>=1)';
    indexV = (nCoV.storage.svsel(k,:)==2)';
    
    % ���ǵ�������
    satnav = satnavSolveWeighted(sv(indexV,:), NF.rp);
    
    % �����˲�
    NF.run(sv, indexP, indexV);
    
    % �洢���
    output.satnav(k,:) = satnav;
    output.pos(k,:) = NF.pos;
    output.vel(k,:) = NF.vel;
    output.clk(k,:) = [NF.dtr, NF.dtv];
    output.P(k,:) = sqrt(diag(NF.P));
end

%% ��λ�����
t = nCoV.storage.ta - nCoV.storage.ta(1);
t = t + nCoV.Tms/1000 - t(end);
figure('Name','λ��')
for k=1:3
    subplot(3,1,k)
    plot(t,[output.satnav(:,k),output.pos(:,k)])
    grid on
end

%% ���ٶ����
figure('Name','�ٶ�')
for k=1:3
    subplot(3,1,k)
    plot(t,[output.satnav(:,k+6),output.vel(:,k)])
    grid on
end

%% ���Ӳ���Ƶ��
figure('Name','�Ӳ���Ƶ��')
subplot(2,1,1)
plot(t,[output.satnav(:,13),output.clk(:,1)])
grid on
subplot(2,1,2)
plot(t,[output.satnav(:,14),output.clk(:,2)])
grid on