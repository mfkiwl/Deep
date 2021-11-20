function pos_normal(obj)
% ������λ

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
end

% ���ǵ�������
if obj.GPSflag==1 && obj.BDSflag==0
    satnav = satnavGPS;
elseif obj.GPSflag==0 && obj.BDSflag==1
    satnav = satnavBDS;
elseif obj.GPSflag==1 && obj.BDSflag==1
    sv = [svGPS; svBDS];
    svIndex = [svIndexGPS; svIndexBDS];
    satnav = satnavSolveWeighted(sv(svIndex,:), obj.rp);
end
dtr = satnav(13); %���ջ��Ӳ�,s
dtv = satnav(14); %���ջ���Ƶ��,s/s

% ���½��ջ�λ���ٶ�
if ~isnan(satnav(1))
    obj.pos = satnav(1:3);
    obj.rp  = satnav(4:6);
    obj.vel = satnav(7:9);
    obj.vp  = satnav(10:12);
    obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
end

% ���ջ�ʱ������
if ~isnan(dtr)
    T = obj.dtpos/1000; %��λʱ����,s
    tv_corr = 10*dtv*T; %��Ƶ��������
    tr_corr = 10*dtr*T; %�Ӳ�������
    obj.deltaFreq = obj.deltaFreq + tv_corr;
    obj.ta = obj.ta - sec2smu(tr_corr);
    obj.clockError = obj.clockError + tr_corr; %�ۼ��Ӳ�������
end

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
m = obj.ns;
obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(m) = obj.deltaFreq;
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
if obj.GPSflag==1
    obj.storage.satnavGPS(m,:) = satnavGPS([1,2,3,7,8,9,13,14]);
    obj.storage.svselGPS(m,:) = svIndexGPS + svIndexGPS;
end
if obj.BDSflag==1
    obj.storage.satnavBDS(m,:) = satnavBDS([1,2,3,7,8,9,13,14]);
    obj.storage.svselBDS(m,:) = svIndexBDS + svIndexBDS;
end
obj.storage.pos(m,:) = obj.pos;
obj.storage.vel(m,:) = obj.vel;

% �����´ζ�λʱ��
obj.tp = timeCarry(obj.tp + [0,obj.dtpos,0]);

end