function pos_tight(obj)
% ����϶�λ

% ��ȡ���ǲ�����Ϣ & ��ȡͨ����Ϣ & �������ǵ�������
if obj.GPSflag==1
    satmeasGPS = obj.get_satmeasGPS; %���ǲ�����Ϣ
    [~, ele] = aziele_xyz(satmeasGPS(:,1:3), obj.pos); %���Ǹ߶Ƚ�
    eleError = 5*(1-1./(1+exp(-((ele-30)/5)))); %�߶Ƚ���������
    %---------------------------------------------------------------------%
    chN = obj.GPS.chN;
    CN0 = zeros(chN,1); %�����
    R_rho = zeros(chN,1); %α�������������,m^2
    R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
    for k=1:chN
        channel = obj.GPS.channels(k);
        if channel.state==2
            CN0(k) = channel.CN0;
            R_rho(k) = (sqrt(channel.varValue(1))+eleError(k))^2;
            R_rhodot(k) = channel.varValue(2);
        end
    end
    svGPS = [satmeasGPS(:,1:8), R_rho, R_rhodot];
    %---------------------------------------------------------------------%
    svIndexGPS = CN0>=obj.CN0Thr.strong; %ѡ��
    satnavGPS = satnavSolveWeighted(svGPS(svIndexGPS,:), obj.rp);
    indexP_GPS = CN0>=obj.CN0Thr.middle; %ʹ��α�������
    indexV_GPS = CN0>=obj.CN0Thr.strong; %ʹ��α���ʵ�����
end
if obj.BDSflag==1
    satmeasBDS = obj.get_satmeasBDS; %���ǲ�����Ϣ
    [~, ele] = aziele_xyz(satmeasBDS(:,1:3), obj.pos); %���Ǹ߶Ƚ�
    eleError = 5*(1-1./(1+exp(-((ele-30)/5)))); %�߶Ƚ���������
    %---------------------------------------------------------------------%
    chN = obj.BDS.chN;
    CN0 = zeros(chN,1); %�����
    R_rho = zeros(chN,1); %α�������������,m^2
    R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
    for k=1:chN
        channel = obj.BDS.channels(k);
        if channel.state==2
            CN0(k) = channel.CN0;
            R_rho(k) = (sqrt(channel.varValue(1))+eleError(k))^2;
            R_rhodot(k) = channel.varValue(2);
        end
    end
    svBDS = [satmeasBDS(:,1:8), R_rho, R_rhodot];
    %---------------------------------------------------------------------%
    svIndexBDS = CN0>=obj.CN0Thr.strong; %ѡ��
    satnavBDS = satnavSolveWeighted(svBDS(svIndexBDS,:), obj.rp);
    indexP_BDS = CN0>=obj.CN0Thr.middle; %ʹ��α�������
    indexV_BDS = CN0>=obj.CN0Thr.strong; %ʹ��α���ʵ�����
end

% ���ǵ������� & �����˲�
if obj.GPSflag==1 && obj.BDSflag==0
    satnav = satnavGPS;
    obj.navFilter.run(obj.imu, svGPS, indexP_GPS, indexV_GPS);
elseif obj.GPSflag==0 && obj.BDSflag==1
    satnav = satnavBDS;
    obj.navFilter.run(obj.imu, svBDS, indexP_BDS, indexV_BDS);
elseif obj.GPSflag==1 && obj.BDSflag==1
    sv = [svGPS; svBDS];
    svIndex = [svIndexGPS; svIndexBDS];
    satnav = satnavSolveWeighted(sv(svIndex,:), obj.rp);
    indexP = [indexP_GPS; indexP_BDS];
    indexV = [indexV_GPS; indexV_BDS];
    obj.navFilter.run(obj.imu, sv, indexP, indexV);
end

% ����ecefϵ�¸˱�λ���ٶ�
Cnb = quat2dcm(obj.navFilter.quat);
Cen = dcmecef2ned(obj.navFilter.pos(1), obj.navFilter.pos(2));
arm = obj.navFilter.arm; %��ϵ�¸˱�ʸ��
wb = obj.imu(1:3) - obj.navFilter.bias(1:3); %���ٶ�,rad/s
r_arm = arm*Cnb*Cen;
v_arm = cross(wb,arm)*Cnb*Cen;

% ���½��ջ�λ���ٶ�
obj.rp = obj.navFilter.rp + r_arm;
obj.vp = obj.navFilter.vp + v_arm;
obj.att = obj.navFilter.att;
obj.pos = ecef2lla(obj.rp);
obj.vel = obj.vp*Cen';
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
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
if obj.GPSflag==1
    obj.storage.satnavGPS(m,:) = satnavGPS([1,2,3,7,8,9,13,14]);
    obj.storage.svselGPS(m,:) = indexP_GPS + indexV_GPS;
end
if obj.BDSflag==1
    obj.storage.satnavBDS(m,:) = satnavBDS([1,2,3,7,8,9,13,14]);
    obj.storage.svselBDS(m,:) = indexP_BDS + indexV_BDS;
end
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