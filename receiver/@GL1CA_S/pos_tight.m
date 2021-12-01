function pos_tight(obj)
% ����϶�λ

% ��ȡ���ǲ�����Ϣ
satmeas = obj.get_satmeas;

% �߶Ƚ���������
[~, ele] = aziele_xyz(satmeas(:,1:3), obj.pos); %���Ǹ߶Ƚ�
eleError = 5*(1-1./(1+exp(-((ele-30)/5))));

% ��ȡͨ����Ϣ
chN = obj.chN;
CN0 = zeros(chN,1); %�����
R_rho = zeros(chN,1); %α�������������,m^2
R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
R_phase = zeros(chN,1); %�ز���λ������������,(circ)^2
for k=1:chN
    channel = obj.channels(k);
    if channel.state==2
        CN0(k) = channel.CN0;
        R_rho(k) = (sqrt(channel.varValue(1))+eleError(k))^2;
        R_rhodot(k) = channel.varValue(2);
        R_phase(k) = channel.varValue(4);
    end
end
sv = [satmeas(:,1:8), R_rho, R_rhodot];

% ���ǵ�������
svIndex = CN0>=obj.CN0Thr.strong; %ѡ��
satnav = satnavSolveWeighted(sv(svIndex,:), obj.rp);

% �����˲�
indexP = CN0>=obj.CN0Thr.middle; %ʹ��α�������
indexV = CN0>=obj.CN0Thr.strong; %ʹ��α���ʵ�����
obj.navFilter.run(obj.imu, sv, indexP, indexV);

% �������ϵ�¸˱�λ���ٶ�
Cnb = quat2dcm(obj.navFilter.quat);
Cen = dcmecef2ned(obj.navFilter.pos(1), obj.navFilter.pos(2));
arm = obj.navFilter.arm; %��ϵ�¸˱�ʸ��
wb = obj.imu(1:3) - obj.navFilter.bias(1:3); %���ٶ�,rad/s
r_arm = arm*Cnb;
v_arm = cross(wb,arm)*Cnb;

% ���½��ջ�λ���ٶ�
obj.pos = obj.navFilter.pos + r_arm*obj.navFilter.geogInfo.Cn2g;
obj.vel = obj.navFilter.vel + v_arm;
obj.att = obj.navFilter.att;
obj.rp = lla2ecef(obj.pos);
obj.vp = obj.vel*Cen;
obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);

% ���ջ�ʱ������
obj.deltaFreq = obj.deltaFreq + obj.navFilter.dtv;
obj.navFilter.dtv = 0;
obj.ta = obj.ta - sec2smu(obj.navFilter.dtr);
obj.clockError = obj.clockError + obj.navFilter.dtr;
obj.navFilter.dtr = 0;

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
m = obj.ns;
obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(m) = obj.deltaFreq;
obj.storage.satmeas(:,1:10,m) = sv;
obj.storage.satmeas(:,11,m) = satmeas(:,9); %�ز���λ
obj.storage.satmeas(:,12,m) = R_phase;
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
obj.storage.svsel(m,:) = indexP + indexV;
obj.storage.pos(m,:) = obj.pos;
obj.storage.vel(m,:) = obj.vel;
obj.storage.att(m,:) = obj.att;
obj.storage.imu(m,:) = obj.imu;
obj.storage.bias(m,:) = obj.navFilter.bias;
P = obj.navFilter.P;
obj.storage.P(m,1:size(P,1)) = sqrt(diag(P));
Cnb = quat2dcm(obj.navFilter.quat);
P_angle = var_phi2angle(P(1:3,1:3), Cnb);
obj.storage.P(m,1:3) = sqrt(diag(P_angle));
obj.storage.motion(m) = obj.navFilter.motion.state;

% �����´ζ�λʱ��
obj.tp(1) = NaN;

end