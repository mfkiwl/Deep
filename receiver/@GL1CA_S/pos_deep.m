function pos_deep(obj)
% ����϶�λ

% ����
Lca = 299792458/1575.42e6; %�ز���,m
Lco = 299792458/1.023e6; %�볤,m

% ��ȡ���ǲ�����Ϣ
satmeas = obj.get_satmeas;

% ��ȡͨ����Ϣ
chN = obj.chN;
quality = zeros(chN,1); %�ź�����
codeDisc = zeros(chN,1); %��λ�����������������ƽ��ֵ,m
R_rho = zeros(chN,1); %α�������������,m^2
R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
for k=1:chN
    channel = obj.channels(k);
    if channel.state==3
        quality(k) = channel.quality;
        [co, ~] = channel.getDiscOutput;
        codeDisc(k) = mean(co)*Lco;
        R_rho(k) = 4^2;
        R_rhodot(k) = 0.04^2;
    end
end

% ���ǵ�������
sv = satmeas(quality>=1,:); %ѡ��
satnav = satnavSolve(sv, obj.rp);

% �����˲�
sv = [satmeas, quality, R_rho, R_rhodot];
sv(:,7) = sv(:,7) - codeDisc; %�����볬ǰ,α��ƫ��,�������Ϊ��,�����Ǽ�
obj.navFilter.run(obj.imu, sv);

% ʹ���˲���������������Ծ��������ٶ�
[rho0, rhodot0] = rho_rhodot_cal_ecef(satmeas(:,1:3), satmeas(:,4:6), ...
                  obj.navFilter.rp, obj.navFilter.vp);

% ͨ������
% α���,����λ��ǰ; α����С,�ز�Ƶ�ʿ�
switch obj.deepMode
    case 1
        for k=1:chN
            channel = obj.channels(k);
            if channel.state==3
                channel.markCurrStorage;
                %----����λ����
                dcodePhase = (rho0(k)-satmeas(k,7))/Lco; %����λ������
                channel.remCodePhase = channel.remCodePhase - dcodePhase;
            end
        end
    case 2
        for k=1:chN
            channel = obj.channels(k);
            if channel.state==3
                channel.markCurrStorage;
                %----����λ����
                dcodePhase = (rho0(k)-satmeas(k,7))/Lco; %����λ������
                channel.remCodePhase = channel.remCodePhase - dcodePhase;
                %----�ز�����Ƶ������
                dcarrFreq = (rhodot0(k)-satmeas(k,8))/Lca; %��Թ���Ƶ�ʵ�������
                dcarrFreq = dcarrFreq + (channel.carrNco-channel.carrFreq); %�������Ƶ�ʵ�������
                channel.carrNco = channel.carrNco - dcarrFreq;
            end
        end
end

% �¸��ٵ�ͨ���л�����ϸ��ٻ�·
obj.channel_deep;

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