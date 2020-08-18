function pos_deep(obj)
% ����϶�λ

% ����
Lca = 299792458/1575.42e6; %�ز���,m
Lco = 299792458/1.023e6; %�볤,m

% ��ȡ���ǲ�����Ϣ & ��ȡͨ����Ϣ & �������ǵ�������
if obj.GPSflag==1
    satmeasGPS = obj.get_satmeasGPS; %���ǲ�����Ϣ
    [~, ele] = aziele_xyz(satmeasGPS(:,1:3), obj.pos); %���Ǹ߶Ƚ�
    %---------------------------------------------------------------------%
    chN = obj.GPS.chN;
    quality = zeros(chN,1); %�ź�����
    codeDisc = zeros(chN,1); %��λ�����������������ƽ��ֵ,m
    R_rho = zeros(chN,1); %α�������������,m^2
    R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
    for k=1:chN
        channel = obj.GPS.channels(k);
        if channel.state==3
            quality(k) = channel.quality;
            [co, ~] = channel.getDiscOutput;
            codeDisc(k) = sum(co)/length(co)*Lco;
            R_rho(k) = (sqrt(channel.codeVar.D/length(co))*Lco + 1.2*(1+16*(0.5-ele(k)/180)^3))^2;
            R_rhodot(k) = channel.carrVar.D*(6.15*Lca)^2;
        end
    end
    svGPS = [satmeasGPS, quality, R_rho, R_rhodot]; %���ź��������۵����ǲ�����Ϣ
    svGPS(:,7) = svGPS(:,7) - codeDisc; %�����볬ǰ,α��ƫ��,�������Ϊ��,�����Ǽ�
    %---------------------------------------------------------------------%
    sv = svGPS(svGPS(:,9)>=1,[1:8,10,11]); %ѡ�ź�������Ϊ0������
    satnavGPS = satnavSolveWeighted(sv, obj.rp);
end
if obj.BDSflag==1
    satmeasBDS = obj.get_satmeasBDS; %���ǲ�����Ϣ
    [~, ele] = aziele_xyz(satmeasBDS(:,1:3), obj.pos); %���Ǹ߶Ƚ�
    %---------------------------------------------------------------------%
    chN = obj.BDS.chN;
    quality = zeros(chN,1); %�ź�����
    codeDisc = zeros(chN,1); %��λ�����������������ƽ��ֵ,m
    R_rho = zeros(chN,1); %α�������������,m^2
    R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
    for k=1:chN
        channel = obj.BDS.channels(k);
        if channel.state==3
            quality(k) = channel.quality;
            [co, ~] = channel.getDiscOutput;
            codeDisc(k) = sum(co)/length(co)*Lco;
            R_rho(k) = (sqrt(channel.codeVar.D/length(co))*Lco + 1.2*(1+16*(0.5-ele(k)/180)^3))^2;
            R_rhodot(k) = channel.carrVar.D*(6.15*Lca)^2;
        end
    end
    svBDS = [satmeasBDS, quality, R_rho, R_rhodot]; %���ź��������۵����ǲ�����Ϣ
    svBDS(:,7) = svBDS(:,7) - codeDisc; %�����볬ǰ,α��ƫ��,�������Ϊ��,�����Ǽ�
    %---------------------------------------------------------------------%
    sv = svBDS(svBDS(:,9)>=1,[1:8,10,11]); %ѡ�ź�������Ϊ0������
    satnavBDS = satnavSolveWeighted(sv, obj.rp);
end

% ���ǵ������� & �����˲�
if obj.GPSflag==1 && obj.BDSflag==0
    satnav = satnavGPS;
    obj.navFilter.run(obj.imu, svGPS);
elseif obj.GPSflag==0 && obj.BDSflag==1
    satnav = satnavBDS;
    obj.navFilter.run(obj.imu, svBDS);
elseif obj.GPSflag==1 && obj.BDSflag==1
    sv = [svGPS(svGPS(:,9)>=1,[1:8,10,11]); svBDS(svBDS(:,9)>=1,[1:8,10,11])];
    satnav = satnavSolveWeighted(sv, obj.rp);
    obj.navFilter.run(obj.imu, [svGPS;svBDS]);
end

% ����ecefϵ�¼��ٶ�
Cnb = quat2dcm(obj.navFilter.quat);
Cen = dcmecef2ned(obj.navFilter.pos(1), obj.navFilter.pos(2));
fb = (obj.imu(4:6) - obj.navFilter.bias(4:6)) * obj.navFilter.g; %�ߵ����ٶ�,m/s^2
wb = (obj.imu(1:3) - obj.navFilter.bias(1:3)) /180*pi; %���ٶ�,rad/s
wdot = obj.navFilter.wdot /180*pi; %�Ǽ��ٶ�,rad/s/s
arm = obj.navFilter.arm; %��ϵ�¸˱�ʸ��
fbt = cross(wdot,arm); %������ٶ�,m/s^2
fbn = cross(wb,cross(wb,arm)); %������ٶ�,m/s^2
fn = (fb+fbt+fbn)*Cnb + [0,0,obj.navFilter.g]; %����ϵ�¼��ٶ�
fe = fn*Cen; %ecefϵ�¼��ٶ�

% ����ecefϵ�¸˱�λ���ٶ�
r_arm = arm*Cnb*Cen;
v_arm = cross(wb,arm)*Cnb*Cen;

% �ߵ�λ���ٶ����˱�������õ�����λ���ٶ�
obj.rp = obj.navFilter.rp + r_arm;
obj.vp = obj.navFilter.vp + v_arm;
obj.att = obj.navFilter.att;
obj.pos = ecef2lla(obj.rp);
obj.vel = obj.vp*Cen';

% ͨ������
if obj.GPSflag==1
    satmeas = satmeasGPS;
    [rho0, rhodot0, rspu] = rho_rhodot_cal_ecef(satmeas(:,1:3), satmeas(:,4:6), ...
                            obj.rp, obj.vp); %������Ծ��������ٶ�
    acclos0 = rspu*fe'; %������ջ��˶��������Լ��ٶ�
    if obj.deepMode==1 %ֻ������λ
        for k=1:obj.GPS.chN
            channel = obj.GPS.channels(k);
            if channel.state==3
                channel.markCurrStorage;
                %----����λ����
                dcodePhase = (rho0(k)-satmeas(k,7))/Lco; %����λ������
                channel.remCodePhase = channel.remCodePhase - dcodePhase;
                %----���ջ��˶�������ز�Ƶ�ʱ仯��
                channel.carrAccR = -acclos0(k)/Lca;
            end
        end
    elseif obj.deepMode==2 %������λ���ز�����Ƶ��
        for k=1:obj.GPS.chN
            channel = obj.GPS.channels(k);
            if channel.state==3
                channel.markCurrStorage;
                %----����λ����
                dcodePhase = (rho0(k)-satmeas(k,7))/Lco; %����λ������
                channel.remCodePhase = channel.remCodePhase - dcodePhase;
                %----�ز�����Ƶ������
                dcarrFreq = (rhodot0(k)-satmeas(k,8))/Lca; %��Թ���Ƶ�ʵ�������
%                 dcarrFreq = dcarrFreq + (channel.carrNco-channel.carrFreq); %�������Ƶ�ʵ�������
%                 channel.carrNco = channel.carrNco - dcarrFreq;
                channel.carrNco = channel.carrFreq - dcarrFreq; %�����еļ�д
                %----���ջ��˶�������ز�Ƶ�ʱ仯��
                channel.carrAccR = -acclos0(k)/Lca;
            end
        end
    end
end
if obj.BDSflag==1
    satmeas = satmeasBDS;
    [rho0, rhodot0, rspu] = rho_rhodot_cal_ecef(satmeas(:,1:3), satmeas(:,4:6), ...
                            obj.rp, obj.vp); %������Ծ��������ٶ�
    acclos0 = rspu*fe'; %������ջ��˶��������Լ��ٶ�
    if obj.deepMode==1 %ֻ������λ
        for k=1:obj.BDS.chN
            channel = obj.BDS.channels(k);
            if channel.state==3
                channel.markCurrStorage;
                %----����λ����
                dcodePhase = (rho0(k)-satmeas(k,7))/Lco*2; %����λ������(���ز�)
                channel.remCodePhase = channel.remCodePhase - dcodePhase;
                %----���ջ��˶�������ز�Ƶ�ʱ仯��
                channel.carrAccR = -acclos0(k)/Lca;
            end
        end
    elseif obj.deepMode==2 %������λ���ز�����Ƶ��
        for k=1:obj.BDS.chN
            channel = obj.BDS.channels(k);
            if channel.state==3
                channel.markCurrStorage;
                %----����λ����
                dcodePhase = (rho0(k)-satmeas(k,7))/Lco*2; %����λ������(���ز�)
                channel.remCodePhase = channel.remCodePhase - dcodePhase;
                %----�ز�����Ƶ������
                dcarrFreq = (rhodot0(k)-satmeas(k,8))/Lca; %��Թ���Ƶ�ʵ�������
%                 dcarrFreq = dcarrFreq + (channel.carrNco-channel.carrFreq); %�������Ƶ�ʵ�������
%                 channel.carrNco = channel.carrNco - dcarrFreq;
                channel.carrNco = channel.carrFreq - dcarrFreq; %�����еļ�д
                %----���ջ��˶�������ز�Ƶ�ʱ仯��
                channel.carrAccR = -acclos0(k)/Lca;
            end
        end
    end
end

% �¸��ٵ�ͨ���л�����ϸ��ٻ�·
obj.channel_deep;

% ���ջ�ʱ������
obj.deltaFreq = obj.deltaFreq + obj.navFilter.dtv;
obj.ta = obj.ta - sec2smu(obj.navFilter.dtr);

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
m = obj.ns;
obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(m) = obj.deltaFreq;
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
if obj.GPSflag==1
    obj.storage.satnavGPS(m,:) = satnavGPS([1,2,3,7,8,9,13,14]);
    obj.storage.qualGPS(m,:) = svGPS(:,9);
end
if obj.BDSflag==1
    obj.storage.satnavBDS(m,:) = satnavBDS([1,2,3,7,8,9,13,14]);
    obj.storage.qualBDS(m,:) = svBDS(:,9);
end
obj.storage.pos(m,:) = obj.pos;
obj.storage.vel(m,:) = obj.vel;
obj.storage.att(m,:) = obj.att;
obj.storage.imu(m,:) = obj.imu;
obj.storage.bias(m,:) = obj.navFilter.bias;
P = obj.navFilter.P;
obj.storage.P(m,:) = sqrt(diag(P)); %P(m,1:size(P,1))
Cnb = quat2dcm(obj.navFilter.quat);
P_angle = var_phi2angle(P(1:3,1:3), Cnb);
obj.storage.P(m,1:3) = sqrt(diag(P_angle));
obj.storage.motion(m) = obj.navFilter.motion.state;

% �����´ζ�λʱ��
obj.tp(1) = NaN;

end