function pos_deep(obj)
% ����϶�λ

% ����
Lca = 0.190293672798365; %�ز�����,m (299792458/1575.42e6)
Lco = 293.0522561094819; %�볤,m (299792458/1.023e6)

% ��ȡ���ǲ�����Ϣ
satmeas = obj.get_satmeas;

% �߶Ƚ���������
[~, ele] = aziele_xyz(satmeas(:,1:3), obj.pos); %���Ǹ߶Ƚ�
eleError = 5*(1-1./(1+exp(-((ele-30)/5))));

% ��ȡͨ����Ϣ
chN = obj.chN;
CN0 = zeros(chN,1); %�����
codeDisc = zeros(chN,1); %��λ�����������������ƽ��ֵ,��Ƭ
R_rho = zeros(chN,1); %α�������������,m^2
R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
R_phase = zeros(chN,1); %�ز���λ������������,(circ)^2
if obj.vectorMode==1 || obj.vectorMode==2 %������������໷
    for k=1:chN
        channel = obj.channels(k);
        if channel.state==3
            n = channel.discBuffPtr; %���������������ݸ���
            if n>0 %��λ�����������������
                CN0(k) = channel.CN0;
                codeDisc(k) = sum(channel.discBuff(1,1:n))/n;
                R_rho(k) = (sqrt(channel.varValue(3)/n)+eleError(k))^2;
                R_rhodot(k) = channel.varValue(2);
                R_phase(k) = channel.varValue(4);
                channel.discBuffPtr = 0;
            end
        end
    end
    sv = [satmeas(:,1:8), R_rho, R_rhodot];
    sv(:,7) = sv(:,7) - codeDisc*Lco; %����������������α��,�����볬ǰ,α��ƫ��,�������Ϊ��,�����Ǽ�
elseif obj.vectorMode==4 %��������ͼ�Ƶ��
    freqDisc = zeros(chN,1); %��λ����ڵļ�Ƶ���,Hz
%     phaseError = zeros(chN,1); %�ز���λ���,��
    for k=1:chN
        channel = obj.channels(k);
        if channel.state==3
            n = channel.discBuffPtr;
            if n>1 %��λ�����������������,������������
                CN0(k) = channel.CN0;
                codeDisc(k) = sum(channel.discBuff(1,1:n))/n;
                R_rho(k) = (sqrt(channel.varValue(3)/n)+eleError(k))^2;
%                 [phaseError(k), freqDisc(k), R_freq] = freqError_cal(channel.discBuff(2,1:n), ...
%                 channel.coherentTime, channel.varValue(5));
%                 R_rhodot(k) = R_freq*Lca^2;
                freqDisc(k) = sum(channel.discBuff(3,1:n))/n;
                R_rhodot(k) = channel.varValue(5)*2*(Lca/channel.coherentTime/n)^2;
                R_phase(k) = channel.varValue(4);
                channel.discBuffPtr = 0;
            end
        end
    end
    sv = [satmeas(:,1:8), R_rho, R_rhodot];
    sv(:,7) = sv(:,7) - codeDisc*Lco;
    sv(:,8) = sv(:,8) - freqDisc*Lca;
end

% ���ǵ�������
svIndex = CN0>=obj.CN0Thr.strong; %ѡ��
satnav = satnavSolveWeighted(sv(svIndex,:), obj.rp);

% �����˲�
indexP = CN0>=obj.CN0Thr.middle; %ʹ��α�������
indexV = CN0>=obj.CN0Thr.strong; %ʹ��α���ʵ�����
obj.navFilter.run(obj.imu, sv, indexP, indexV);

% ����ecefϵ�¼��ٶ�
Cnb = quat2dcm(obj.navFilter.quat);
Cen = dcmecef2ned(obj.navFilter.pos(1), obj.navFilter.pos(2));
fb = obj.imu(4:6) - obj.navFilter.bias(4:6); %�ߵ����ٶ�,m/s^2
wb = obj.imu(1:3) - obj.navFilter.bias(1:3); %���ٶ�,rad/s
wdot = obj.navFilter.wdot; %�Ǽ��ٶ�,rad/s^2
arm = obj.navFilter.arm; %��ϵ�¸˱�ʸ��
fbt = cross(wdot,arm); %������ٶ�,m/s^2
fbn = cross(wb,cross(wb,arm)); %������ٶ�,m/s^2
fh = cross(2*obj.geogInfo.wien+obj.geogInfo.wenn, obj.vel); %�к����ٶ�
fn = (fb+fbt+fbn)*Cnb + [0,0,obj.geogInfo.g] - fh; %����ϵ�¼��ٶ�(�ٳ��к����ٶ�)
% fe = fn*Cen; %ecefϵ�¼��ٶ�
%----���ư벽
if isnan(obj.fn0)
    fn1 = fn;
else
    fn1 = (3*fn-obj.fn0)/2;
end
obj.fn0 = fn;
fe = fn1*Cen; %ecefϵ�¼��ٶ�

% �������ϵ�¸˱�λ���ٶ�
r_arm = arm*Cnb;
v_arm = cross(wb,arm)*Cnb;

% �ߵ�λ���ٶ����˱�������õ�����λ���ٶ�
obj.pos = obj.navFilter.pos + r_arm*obj.navFilter.geogInfo.Cn2g;
obj.vel = obj.navFilter.vel + v_arm;
obj.att = obj.navFilter.att;
obj.rp = lla2ecef(obj.pos);
obj.vp = obj.vel*Cen;
obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);

[rho0, rhodot0, rspu] = rho_rhodot_cal_ecef(satmeas(:,1:3), satmeas(:,4:6), ...
                        obj.rp, obj.vp); %������Ծ��������ٶ�
acclos0 = rspu*fe'; %������ջ��˶��������Լ��ٶ�

% ͨ������ (α���,����λ��ǰ; α����С,�ز�Ƶ�ʿ�)
Cdf = 1 + obj.deltaFreq; %����Ƶ�ʵ���ʵƵ�ʵ�ϵ��
dtr_code = obj.navFilter.dtr * 1.023e6; %�Ӳ��Ӧ������λ
dtv_carr = obj.navFilter.dtv * 1575.42e6; %��Ƶ���Ӧ���ز�Ƶ��
if obj.vectorMode==1 %ֻ������λ
    for k=1:chN
        channel = obj.channels(k);
        if channel.state==3
            %----����λ����(satmeas�е�α���Ǵ��Ӳ��,��Ҫ������,���ܵõ�������)
            dcodePhase = (rho0(k)-satmeas(k,7))/Lco + dtr_code; %����λ������
            channel.remCodePhase = channel.remCodePhase - dcodePhase;
            %----���ջ��˶�������ز�Ƶ�ʱ仯��
            channel.carrAccR = -acclos0(k)/Lca / Cdf;
        end
    end
elseif obj.vectorMode==2 %������λ���ز�����Ƶ��
    for k=1:chN
        channel = obj.channels(k);
        if channel.state==3
            %----����λ����(satmeas�е�α���Ǵ��Ӳ��,��Ҫ������,���ܵõ�������)
            dcodePhase = (rho0(k)-satmeas(k,7))/Lco + dtr_code; %����λ������
            channel.remCodePhase = channel.remCodePhase - dcodePhase;
            %----�ز�����Ƶ������(satmeas�е�α�����Ǵ���Ƶ���,��Ҫ������,���ܵõ�������)
            dcarrFreq = (rhodot0(k)-satmeas(k,8))/Lca + dtv_carr; %��Թ���Ƶ�ʵ�������
            channel.carrNco = channel.carrFreq - dcarrFreq/Cdf;
            %----���ջ��˶�������ز�Ƶ�ʱ仯��
            channel.carrAccR = -acclos0(k)/Lca / Cdf;
        end
    end
elseif obj.vectorMode==4 %������λ���ز�����Ƶ��(�ز�����)
    for k=1:chN
        channel = obj.channels(k);
        if channel.state==3
            %----����λ����
            dcodePhase = (rho0(k)-satmeas(k,7))/Lco + dtr_code;
            channel.remCodePhase = channel.remCodePhase - dcodePhase;
            %----�ز�����Ƶ������
            dcarrFreq = (rhodot0(k)-satmeas(k,8))/Lca + dtv_carr;
            channel.carrNco = channel.carrFreq - dcarrFreq/Cdf;
            channel.carrFreq = channel.carrNco; %ֱ�Ӹ�ֵ
            %----�ز���λ����
%             channel.remCarrPhase = mod(channel.remCarrPhase+phaseError(k)*0.5, 1);
            %----���ջ��˶�������ز�Ƶ�ʱ仯��
            channel.carrAccR = -acclos0(k)/Lca / Cdf;
        end
    end
else
    error('vectorMode error!')
end

% �¸��ٵ�ͨ���л�ʸ�����ٻ�·
obj.channel_vector;

% ���ջ�ʱ������
% obj.deltaFreq = obj.deltaFreq + obj.navFilter.dtv;
% obj.navFilter.dtv = 0;
% obj.ta = obj.ta - sec2smu(obj.navFilter.dtr);
% obj.clockError = obj.clockError + obj.navFilter.dtr;
% obj.navFilter.dtr = 0;

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
obj.storage.others(m,1:3) = obj.navFilter.arm;
obj.storage.others(m,4:6) = obj.navFilter.wdot;
% obj.storage.others(m,7) = obj.navFilter.delay;
obj.storage.others(m,8) = obj.navFilter.dtr;
obj.storage.others(m,9) = obj.navFilter.dtv;
obj.storage.others(m,10:12) = fn;

% �����´ζ�λʱ��
obj.tp(1) = NaN;

end