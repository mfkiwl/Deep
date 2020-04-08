function pos_tight(obj)
% �����ģʽ��λ

% ��ȡ���ǲ�����Ϣ
satmeas = obj.get_satmeas;

% ��ȡͨ����Ϣ
chN = obj.chN;
quality = zeros(chN,1); %�ź�����
R_rho = zeros(chN,1); %α�������������,m^2
R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
for k=1:chN
    channel = obj.channels(k);
    if channel.state==2 %ͨ�����Բ���α��α����
        quality(k) = channel.quality;
        R_rho(k) = 4^2;
        R_rhodot(k) = 0.04^2;
    end
end

% ���ǵ�������
sv = satmeas(quality>=1,:); %ѡ��
satnav = satnavSolve(sv, obj.rp);

% �����˲�
sv = [satmeas, quality, R_rho, R_rhodot];
obj.navFilter.run(obj.imu, sv);

% ���½��ջ�λ���ٶ�
obj.pos = obj.navFilter.pos;
obj.vel = obj.navFilter.vel;
obj.att = obj.navFilter.att;
obj.rp = obj.navFilter.rp;
obj.vp = obj.navFilter.vp;

% ���ջ�ʱ������
obj.deltaFreq = obj.deltaFreq + obj.navFilter.dtv;
obj.ta = obj.ta - sec2smu(obj.navFilter.dtr);

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
m = obj.ns;
obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(m) = obj.deltaFreq;
obj.storage.satmeas(:,:,m) = satmeas;
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
obj.storage.pos(m,:) = obj.pos;
obj.storage.vel(m,:) = obj.vel;
obj.storage.att(m,:) = obj.att;
obj.storage.imu(m,:) = obj.imu;
obj.storage.bias(m,:) = obj.navFilter.bias;
P = obj.navFilter.P;
obj.storage.P(m,:) = sqrt(diag(P));
Cnb = quat2dcm(obj.navFilter.quat);
P_angle = var_phi2angle(P(1:3,1:3), Cnb);
obj.storage.P(m,1:3) = sqrt(diag(P_angle));

% �����´ζ�λʱ��
obj.tp(1) = NaN;

end